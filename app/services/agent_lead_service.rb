class AgentLeadService
  RESPONSE_SCHEMA = {
    type: "object",
    additionalProperties: false,
    required: %w[assistant_message name email phone interested_in should_create_lead],
    properties: {
      assistant_message: { type: "string" },
      name: { type: %w[string null] },
      email: { type: %w[string null] },
      phone: { type: %w[string null] },
      interested_in: {
        type: "array",
        items: { type: "string" }
      },
      should_create_lead: { type: "boolean" }
    }
  }.freeze

  REQUIRED_FIELDS = %w[name email interested_in].freeze

  def initialize(message:, state:, client: Openai::ResponsesClient.new)
    @message = message.to_s.strip
    @state = state.deep_stringify_keys
    @client = client
  end

  def call
    raise ArgumentError, "Message can't be blank" if @message.blank?

    ai_response = @client.create_json_response!(
      input: @message,
      instructions: prompt,
      schema: RESPONSE_SCHEMA,
      previous_response_id: @state["previous_response_id"]
    )

    payload = ai_response.fetch(:parsed).deep_stringify_keys
    collected = merge_collected_data(payload)
    lead = maybe_create_lead!(payload:, collected:)
    conversation_closed = lead.present?
    assistant_message = finalize_message(payload["assistant_message"], lead:)

    {
      assistant_message: assistant_message,
      lead_created: lead.present?,
      lead_id: lead&.id,
      collected: collected,
      conversation_closed: conversation_closed,
      session_state: conversation_closed ? {} : @state.merge(
        "previous_response_id" => ai_response[:response_id],
        "lead_id" => lead&.id || @state["lead_id"],
        "collected" => collected
      )
    }
  end

  private

  def prompt
    <<~PROMPT
      You are Iron Cars Shop's polite lead-capture assistant for visitors who are not logged in.

      Your goals, in order:
      1. Help the visitor find a vehicle.
      2. Capture the visitor's full name and email as early as possible.
      3. Confirm whether the visitor is looking in a specific region. If they care about location, ask for the city and/or state. If they do not care, record that they want the best overall offer available.
      4. Infer a clean interested_in array from the conversation, using short tags like brand, model, series, year, body style, doors, budget, city, state, or region_preference.
      5. Once name, email, and interested_in are all known, summarize what you captured and ask for a quick confirmation that the visitor is done sharing details.
      6. Only set should_create_lead=true after the visitor clearly confirms they are done, says that's all, asks you to proceed, or otherwise gives an explicit closing confirmation.
      7. After that, you may ask for phone, but reassure the visitor that you already found good options and that a specialized agent will contact them by email soon with the best regional offer.

      Conversation rules:
      - Be warm, concise, and proactive.
      - Ask only one or two short questions at a time.
      - If name or email is missing, prioritize those before deeper qualification.
      - If region preference is unknown, ask whether the visitor wants offers from a specific city/state or the best overall match regardless of region.
      - If the visitor says location does not matter, add a tag like region_preference:best_overall.
      - If the visitor wants a specific place, capture city and/or state explicitly in interested_in.
      - Do not close the chat immediately after collecting the minimum fields. Always wait for explicit user confirmation first.
      - Never claim a lead was created. You only indicate readiness by setting should_create_lead=true.
      - Keep interested_in focused and deduplicated.
      - Always return valid JSON matching the schema.

      Already collected data:
      #{JSON.pretty_generate(@state["collected"].presence || {})}
    PROMPT
  end

  def merge_collected_data(payload)
    current = @state.fetch("collected", {})

    {
      "name" => payload["name"].to_s.strip.presence || current["name"],
      "email" => normalize_email(payload["email"]) || current["email"],
      "phone" => payload["phone"].to_s.strip.presence || current["phone"],
      "interested_in" => merge_interested_in(current["interested_in"], payload["interested_in"])
    }
  end

  def merge_interested_in(existing, incoming)
    Array(existing).concat(Array(incoming)).filter_map do |item|
      item.to_s.strip.presence
    end.uniq
  end

  def maybe_create_lead!(payload:, collected:)
    return Lead.find_by(id: @state["lead_id"]) if @state["lead_id"].present?
    return unless required_fields_present?(collected)
    return unless payload["should_create_lead"] || explicit_closing_signal?

    Lead.create!(
      name: collected["name"],
      email: collected["email"],
      phone: collected["phone"],
      interested_in: collected["interested_in"],
      source: :agent_lead,
      status: :qualified
    )
  end

  def required_fields_present?(collected)
    REQUIRED_FIELDS.all? do |field|
      value = collected[field]
      value.is_a?(Array) ? value.any? : value.present?
    end
  end

  def finalize_message(message, lead:)
    base_message = message.to_s.strip
    return base_message if lead.blank?

    closing = " I already found some promising vehicles here, and a specialized agent will reach out by email soon with the best offer in your area. This chat is now complete."
    base_message.include?("specialized agent") ? base_message : "#{base_message}#{closing}"
  end

  def normalize_email(value)
    email = value.to_s.strip.downcase
    email.match?(URI::MailTo::EMAIL_REGEXP) ? email : nil
  end

  def explicit_closing_signal?
    normalized = @message.downcase

    [
      "that's all",
      "thats all",
      "just that",
      "that's it",
      "thats it",
      "all good",
      "looks good",
      "you can proceed",
      "go ahead",
      "done",
      "finished",
      "thank you",
      "thanks",
      "for now",
      "perfeito",
      "pode seguir",
      "pode prosseguir",
      "isso mesmo",
      "é isso",
      "ta ok",
      "tá ok",
      "ok"
    ].any? { |token| normalized.include?(token) }
  end
end

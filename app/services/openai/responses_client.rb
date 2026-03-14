require "json"
require "net/http"

module Openai
  class ResponsesClient
    OPENAI_URL = URI("https://api.openai.com/v1/responses")

    def initialize(api_key: ENV["OPENAI_API_KEY"], model: ENV.fetch("OPENAI_LEAD_AGENT_MODEL", "gpt-5-mini"))
      @api_key = api_key
      @model = model
    end

    def create_json_response!(input:, instructions:, schema:, previous_response_id: nil)
      raise ArgumentError, "OPENAI_API_KEY is not configured" if @api_key.blank?

      payload = {
        model: @model,
        store: true,
        instructions: instructions,
        input: input,
        text: {
          format: {
            type: "json_schema",
            name: "lead_chat_turn",
            strict: true,
            schema: schema
          }
        }
      }

      payload[:previous_response_id] = previous_response_id if previous_response_id.present?

      response = Net::HTTP.start(OPENAI_URL.host, OPENAI_URL.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(OPENAI_URL)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(payload)
        http.request(request)
      end

      body = JSON.parse(response.body)
      raise StandardError, body.dig("error", "message") || "OpenAI request failed" unless response.is_a?(Net::HTTPSuccess)

      {
        response_id: body["id"],
        parsed: parse_output(body)
      }
    end

    private

    def parse_output(body)
      return body["output_parsed"] if body["output_parsed"].present?
      return JSON.parse(body["output_text"]) if body["output_text"].present?

      item = Array(body["output"]).find { |entry| entry["type"] == "message" }
      content = Array(item&.dig("content")).find { |entry| entry["type"] == "output_text" }

      JSON.parse(content&.dig("text").to_s)
    rescue JSON::ParserError
      raise StandardError, "OpenAI returned an invalid JSON payload"
    end
  end
end

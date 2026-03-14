class LeadChatMessagesController < ApplicationController
  def create
    result = AgentLeadService.new(
      message: params.require(:message),
      state: lead_chat_session
    ).call

    if result[:session_state].present?
      session[:lead_chat] = result[:session_state]
    else
      session.delete(:lead_chat)
    end

    render json: {
      assistant_message: result[:assistant_message],
      lead_created: result[:lead_created],
      lead_id: result[:lead_id],
      collected: result[:collected],
      conversation_closed: result[:conversation_closed]
    }
  rescue ActionController::ParameterMissing, ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: {
      error: "We couldn't continue the assistant right now.",
      detail: Rails.env.development? ? e.message : nil
    }, status: :service_unavailable
  end

  private

  def lead_chat_session
    session[:lead_chat] ||= {}
  end
end

class NegotiationMailer < ApplicationMailer
  def new_message_notification(message, recipient)
    @message = message
    @recipient = recipient
    @negotiation = message.negotiation
    @sender_name = message.user&.full_name.presence || message.user&.email || @negotiation.lead&.name || @negotiation.lead&.email || "A buyer"

    mail(to: recipient.email, subject: "New message in your Iron Cars negotiation")
  end
end

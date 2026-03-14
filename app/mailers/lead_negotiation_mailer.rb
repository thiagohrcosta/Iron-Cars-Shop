class LeadNegotiationMailer < ApplicationMailer
  default from: "support@ironcars.com"

  def seller_message_notification(message)
    @message = message
    @negotiation = message.negotiation
    @negotiation.ensure_public_access_token!
    @lead = @negotiation.lead
    @seller = @negotiation.seller
    @vehicle = @negotiation.vehicle
    @conversation_url = public_lead_negotiation_url(token: @negotiation.public_access_token)

    mail(
      to: @lead.email,
      subject: "#{@seller.full_name.presence || @seller.email} responded about #{@vehicle.full_name}"
    )
  end
end

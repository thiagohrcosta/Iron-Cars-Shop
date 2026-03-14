class Public::LeadNegotiationMessagesController < ApplicationController
  before_action :set_negotiation

  def create
    @message = @negotiation.negotiation_messages.build(message_params)
    @message.user = nil

    if @message.save
      redirect_to public_lead_negotiation_path(@negotiation.public_access_token), notice: "Message sent."
    else
      @messages = @negotiation.negotiation_messages.includes(:user).order(:created_at)
      render "public/lead_negotiations/show", status: :unprocessable_entity
    end
  end

  private

  def set_negotiation
    @negotiation = Negotiation.includes(:lead, :seller, vehicle: [ { car_model: :brand }, photos_attachments: :blob ])
      .find_by!(public_access_token: params[:token])
  end

  def message_params
    params.require(:negotiation_message).permit(:content)
  end
end

class Public::LeadNegotiationsController < ApplicationController
  before_action :set_negotiation

  def show
    @messages = @negotiation.negotiation_messages.includes(:user).order(:created_at)
    @message = @negotiation.negotiation_messages.build
  end

  private

  def set_negotiation
    @negotiation = Negotiation.includes(:lead, :seller, vehicle: [ { car_model: :brand }, photos_attachments: :blob ])
      .find_by!(public_access_token: params[:token])
  end
end

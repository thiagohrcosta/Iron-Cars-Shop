class User::NegotiationMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_negotiation

  def create
    @message = @negotiation.negotiation_messages.build(message_params)
    @message.user = current_user

    if @message.save
      @message = @negotiation.negotiation_messages.build
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_negotiation_path(@negotiation), notice: "Message sent." }
      end
    else
      @negotiations = Negotiation.for_user(current_user)
        .includes(:buyer, :seller, vehicle: [ :car_model, :photos_attachments, :user ], negotiation_messages: :user)
        .order(updated_at: :desc)
      @selected_negotiation = @negotiation
      @messages = @negotiation.negotiation_messages.order(:created_at)
      render "user/negotiations/index", status: :unprocessable_entity
    end
  end

  private

  def set_negotiation
    @negotiation = Negotiation
      .where(buyer_id: current_user.id)
      .or(Negotiation.where(seller_id: current_user.id))
      .find(params[:negotiation_id])
  end

  def message_params
    params.require(:negotiation_message).permit(:content)
  end
end

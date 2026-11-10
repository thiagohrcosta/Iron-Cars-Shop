class User::NegotiationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_negotiations, only: [ :index, :show ]
  before_action :set_negotiation, only: :show

  def index
    @selected_negotiation = @negotiations.first
    prepare_selected_negotiation
  end

  def show
    @selected_negotiation = @negotiation
    prepare_selected_negotiation(mark_read: true)
    render :index
  end

  def create
    listing = VehicleListing.find_by(id: negotiation_params[:vehicle_listing_id])
    return redirect_to(cars_path, alert: "Listing not found.") unless listing

    @negotiation = Negotiation.open!(listing: listing, buyer: current_user)
    redirect_to user_negotiation_path(@negotiation), notice: "Negotiation created successfully!"
  rescue Negotiation::InvalidTransition => error
    redirect_to car_path(listing.vehicle), alert: error.message
  rescue ActiveRecord::RecordInvalid => error
    redirect_to car_path(listing.vehicle), alert: error.record.errors.full_messages.to_sentence
  end

  private

  def load_negotiations
    @negotiations = Negotiation.for_user(current_user)
      .includes(:buyer, :seller, :lead, vehicle: [ :car_model, :photos_attachments, :user ], negotiation_messages: :user)
      .order(updated_at: :desc)
  end

  def set_negotiation
    @negotiation = Negotiation.for_user(current_user).find(params[:id])
  end

  def prepare_selected_negotiation(mark_read: false)
    return unless @selected_negotiation

    @messages = @selected_negotiation.negotiation_messages.includes(:user).order(:created_at)
    @selected_negotiation.mark_read_for!(current_user) if mark_read
    @message = @selected_negotiation.negotiation_messages.build
  end

  def negotiation_params
    params.fetch(:negotiation, {}).permit(:vehicle_listing_id)
  end
end

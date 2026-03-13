class User::NegotiationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_negotiations, only: [ :index, :show ]
  before_action :set_negotiation, only: [ :show, :make_offer, :accept_offer, :reject_offer ]

  def index
    @selected_negotiation = @negotiations.first
    prepare_selected_negotiation
  end

  def show
    @selected_negotiation = @negotiation
    prepare_selected_negotiation
    render :index
  end

  def create
    listing = VehicleListing.find_by(id: negotiation_params[:vehicle_listing_id])

    unless listing
      redirect_to cars_path, alert: "Listing not found."
      return
    end

    if listing.seller_id == current_user.id
      redirect_to car_path(listing.vehicle), alert: "You cannot negotiate your own vehicle."
      return
    end

    @negotiation = Negotiation.new(
      vehicle_listing: listing,
      vehicle: listing.vehicle,
      buyer: current_user,
      seller: listing.seller,
      price_cents: listing.vehicle.price_cents,
      accepted_by_buyer: false,
      accepted_by_seller: false,
      status: "pending"
    )

    if @negotiation.save
      create_initial_vehicle_message!(@negotiation)
      redirect_to user_negotiation_path(@negotiation), notice: "Negotiation created successfully!"
    else
      redirect_to car_path(listing.vehicle), alert: @negotiation.errors.full_messages.to_sentence
    end
  end

  def make_offer
    unless @negotiation.can_receive_offer_from?(current_user)
      redirect_to user_negotiation_path(@negotiation), alert: "You cannot make an offer on this negotiation."
      return
    end

    offer_cents = parse_price_to_cents(params[:offer_price])

    if offer_cents <= 0
      redirect_to user_negotiation_path(@negotiation), alert: "Enter a valid offer amount."
      return
    end

    @negotiation.update!(
      price_cents: offer_cents,
      accepted_by_buyer: true,
      accepted_by_seller: false,
      status: "pending",
      accepted_at: nil,
      rejected_at: nil
    )

    @negotiation.negotiation_messages.create!(
      user: current_user,
      content: "Offer submitted: #{ApplicationController.helpers.number_to_currency(offer_cents / 100.0, precision: 0)}"
    )

    broadcast_negotiation_meta_to_participants(@negotiation)
    redirect_to user_negotiation_path(@negotiation), notice: "Offer sent successfully."
  end

  def accept_offer
    unless @negotiation.seller?(current_user) && @negotiation.offer_active?
      redirect_to user_negotiation_path(@negotiation), alert: "There is no pending offer to accept."
      return
    end

    Negotiation.transaction do
      @negotiation.update!(
        status: "accepted",
        accepted_by_seller: true,
        accepted_at: Time.current
      )

      @negotiation.vehicle_listing.update!(
        status: "sold",
        expires_at: 30.days.from_now
      )

      @negotiation.negotiation_messages.create!(
        user: current_user,
        content: "Offer accepted. Vehicle marked as SOLD for 30 days."
      )
    end

    broadcast_negotiation_meta_to_participants(@negotiation)
    redirect_to user_negotiation_path(@negotiation), notice: "Offer accepted successfully."
  end

  def reject_offer
    unless @negotiation.seller?(current_user) && @negotiation.offer_active?
      redirect_to user_negotiation_path(@negotiation), alert: "There is no pending offer to reject."
      return
    end

    @negotiation.update!(status: "rejected", rejected_at: Time.current)

    rejection_message = if @negotiation.remaining_offer_attempts.positive?
      remaining = @negotiation.remaining_offer_attempts
      "Offer rejected. Buyer still has #{remaining} more #{remaining == 1 ? 'attempt' : 'attempts'}."
    else
      "Offer rejected. Negotiation closed after reaching the maximum number of offers."
    end

    @negotiation.negotiation_messages.create!(user: current_user, content: rejection_message)

    broadcast_negotiation_meta_to_participants(@negotiation)
    redirect_to user_negotiation_path(@negotiation), notice: "Offer rejected."
  end

  private

  def load_negotiations
    @negotiations = Negotiation.for_user(current_user)
      .includes(:buyer, :seller, vehicle: [ :car_model, :photos_attachments, :user ], negotiation_messages: :user)
      .order(updated_at: :desc)
  end

  def set_negotiation
    @negotiation = Negotiation.for_user(current_user).find(params[:id])
  end

  def prepare_selected_negotiation
    return unless @selected_negotiation

    @messages = @selected_negotiation.negotiation_messages.includes(:user).order(:created_at)
    @message = @selected_negotiation.negotiation_messages.build
  end

  def parse_price_to_cents(value)
    normalized = value.to_s.gsub(/[^\d.,]/, "").tr(",", ".")
    (normalized.to_f * 100).round
  end

  def create_initial_vehicle_message!(negotiation)
    vehicle = negotiation.vehicle
    negotiation.negotiation_messages.create!(
      user: negotiation.seller,
      content: <<~TEXT.squish
        Vehicle information: #{vehicle.full_name}. Listed price #{ApplicationController.helpers.number_to_currency(vehicle.price_cents / 100.0, precision: 0)}.
        #{ApplicationController.helpers.number_with_delimiter(vehicle.mileage)} miles, #{vehicle.transmission.to_s.humanize}, #{vehicle.fuel_type.to_s.humanize}.
      TEXT
    )
  end

  def broadcast_negotiation_meta_to_participants(negotiation)
    [ negotiation.buyer_id, negotiation.seller_id ].uniq.each do |participant_id|
      Turbo::StreamsChannel.broadcast_replace_to(
        negotiation,
        :meta,
        participant_id,
        target: "negotiation_#{negotiation.id}_offer_panel",
        partial: "user/negotiations/offer_panel",
        locals: { negotiation: negotiation, current_user_id: participant_id }
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        negotiation,
        :meta,
        participant_id,
        target: "negotiation_#{negotiation.id}_status_badge",
        partial: "user/negotiations/status_badge",
        locals: { negotiation: negotiation }
      )
    end
  end

  def negotiation_params
    params.fetch(:negotiation, {}).permit(:vehicle_listing_id)
  end
end

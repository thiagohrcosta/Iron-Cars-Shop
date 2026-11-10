# The offer lifecycle: the buyer submits up to MAX_OFFER_ATTEMPTS offers and the
# seller accepts or rejects each one. Every transition checks its own invariant,
# so callers can't skip a rule by forgetting a guard.
module Negotiation::Offering
  extend ActiveSupport::Concern

  MAX_OFFER_ATTEMPTS = 3
  OFFER_MESSAGE_PREFIX = "Offer submitted:"

  class InvalidTransition < StandardError; end

  class_methods do
    # A buyer opens a negotiation on a listing at its asking price; the seller's
    # first message summarizes the vehicle.
    def open!(listing:, buyer:)
      raise InvalidTransition, "You cannot negotiate your own vehicle." if listing.seller_id == buyer.id

      transaction do
        create!(vehicle_listing: listing, vehicle: listing.vehicle, buyer: buyer, seller: listing.seller,
                price_cents: listing.vehicle.price_cents, status: "pending").tap(&:post_vehicle_summary!)
      end
    end
  end

  def submit_offer!(by:, price_cents:)
    raise InvalidTransition, "You cannot make an offer on this negotiation." unless can_receive_offer_from?(by)
    raise InvalidTransition, "Enter a valid offer amount." unless price_cents.to_i.positive?

    transaction do
      update!(price_cents: price_cents, accepted_by_buyer: true, accepted_by_seller: false,
              status: "pending", accepted_at: nil, rejected_at: nil)
      negotiation_messages.create!(user: by, content: "#{OFFER_MESSAGE_PREFIX} #{format_cents(price_cents)}")
    end
  end

  def accept!(by:, at: Time.current)
    ensure_seller_can_answer!(by, "There is no pending offer to accept.")

    transaction do
      update!(status: "accepted", accepted_by_seller: true, accepted_at: at)
      vehicle_listing.mark_sold!(at: at, price_cents: price_cents.round)
      negotiation_messages.create!(
        user: by,
        content: "Offer accepted. Vehicle marked as SOLD for #{VehicleListing::SOLD_BADGE_DURATION.in_days.to_i} days."
      )
    end
  end

  def reject!(by:, at: Time.current)
    ensure_seller_can_answer!(by, "There is no pending offer to reject.")

    transaction do
      update!(status: "rejected", rejected_at: at)
      negotiation_messages.create!(user: by, content: rejection_message)
    end
  end

  def post_vehicle_summary!
    negotiation_messages.create!(user: seller, content: <<~TEXT.squish)
      Vehicle information: #{vehicle.full_name}. Listed price #{format_cents(vehicle.price_cents)}.
      #{ActiveSupport::NumberHelper.number_to_delimited(vehicle.mileage)} miles, #{vehicle.transmission.to_s.humanize}, #{vehicle.fuel_type.to_s.humanize}.
    TEXT
  end

  def offer_active?
    pending? && accepted_by_buyer? && !accepted_by_seller?
  end

  def can_receive_offer_from?(user)
    buyer?(user) && !accepted? && !vehicle_listing&.sold_visible? && !offer_active? && remaining_offer_attempts.positive?
  end

  def offer_attempts_count
    if negotiation_messages.loaded?
      negotiation_messages.count { |message| message.content.to_s.start_with?(OFFER_MESSAGE_PREFIX) }
    else
      negotiation_messages.where("content LIKE ?", "#{OFFER_MESSAGE_PREFIX}%").count
    end
  end

  def remaining_offer_attempts
    [ MAX_OFFER_ATTEMPTS - offer_attempts_count, 0 ].max
  end

  def offer_limit_reached?
    remaining_offer_attempts.zero?
  end

  private

  def ensure_seller_can_answer!(user, message)
    raise InvalidTransition, message unless seller?(user) && offer_active?
  end

  def rejection_message
    remaining = remaining_offer_attempts
    if remaining.positive?
      "Offer rejected. Buyer still has #{remaining} more #{"attempt".pluralize(remaining)}."
    else
      "Offer rejected. Negotiation closed after reaching the maximum number of offers."
    end
  end

  def format_cents(cents)
    ActiveSupport::NumberHelper.number_to_currency(cents / 100.0, precision: 0)
  end
end

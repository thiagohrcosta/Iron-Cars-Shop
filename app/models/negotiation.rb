class Negotiation < ApplicationRecord
  MAX_OFFER_ATTEMPTS = 3

  belongs_to :vehicle_listing
  belongs_to :vehicle
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  has_many :negotiation_messages, dependent: :destroy

  validates :price_cents, presence: true
  validates :price_cents, numericality: { greater_than: 0 }

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }

  def self.for_user(user)
    where(buyer_id: user.id).or(where(seller_id: user.id))
  end

  def buyer?(user)
    buyer_id == user.id
  end

  def seller?(user)
    seller_id == user.id
  end

  def counterpart_for(user)
    buyer?(user) ? seller : buyer
  end

  def offer_active?
    pending? && accepted_by_buyer? && !accepted_by_seller?
  end

  def offer_attempts_count
    if negotiation_messages.loaded?
      negotiation_messages.count { |message| offer_message?(message) }
    else
      negotiation_messages.where("content LIKE ?", "Offer submitted:%").count
    end
  end

  def remaining_offer_attempts
    [ MAX_OFFER_ATTEMPTS - offer_attempts_count, 0 ].max
  end

  def can_receive_offer_from?(user)
    buyer?(user) && !accepted? && !vehicle_listing&.sold_visible? && !offer_active? && remaining_offer_attempts.positive?
  end

  def offer_limit_reached?
    remaining_offer_attempts.zero?
  end

  def listed_price_cents
    vehicle_listing&.vehicle&.price_cents || vehicle&.price_cents || price_cents
  end

  private

  def offer_message?(message)
    message.content.to_s.start_with?("Offer submitted:")
  end
end

class Negotiation < ApplicationRecord
  MAX_OFFER_ATTEMPTS = 3
  LEAD_STALE_WINDOW = 72.hours

  has_secure_token :public_access_token

  belongs_to :vehicle_listing
  belongs_to :vehicle
  belongs_to :buyer, class_name: "User", optional: true
  belongs_to :seller, class_name: "User"
  belongs_to :lead, optional: true

  has_many :negotiation_messages, dependent: :destroy

  validates :price_cents, presence: true
  validates :price_cents, numericality: { greater_than: 0 }

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }

  def self.for_user(user)
    where(buyer_id: user.id).or(where(seller_id: user.id))
  end

  def buyer?(user)
    user.present? && buyer_id == user.id
  end

  def seller?(user)
    user.present? && seller_id == user.id
  end

  def counterpart_for(user)
    buyer?(user) ? seller : buyer
  end

  def counterpart_name_for(user)
    counterpart = counterpart_for(user)
    counterpart&.full_name.presence || counterpart&.email || lead&.name || lead&.email || "Conversation"
  end

  def counterpart_email_for(user)
    counterpart = counterpart_for(user)
    counterpart&.email || lead&.email
  end

  def ensure_public_access_token!
    regenerate_public_access_token if public_access_token.blank?
    public_access_token
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

  def seller_replied?
    negotiation_messages.where(user_id: seller_id).exists?
  end

  def lead_stale_without_offers?
    !accepted? && offer_attempts_count.zero? && created_at <= LEAD_STALE_WINDOW.ago
  end

  def lost_for_lead_pipeline?
    return false if accepted?

    lead_stale_without_offers? || offer_limit_reached?
  end

  def listed_price_cents
    vehicle_listing&.vehicle&.price_cents || vehicle&.price_cents || price_cents
  end

  private

  def offer_message?(message)
    message.content.to_s.start_with?("Offer submitted:")
  end
end

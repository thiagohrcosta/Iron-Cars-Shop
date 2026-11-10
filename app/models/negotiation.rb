class Negotiation < ApplicationRecord
  include Offering, Broadcasting

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

  def unread_messages_count_for(user)
    return 0 unless buyer?(user) || seller?(user)

    messages_unread_by(user).count
  end

  def unread_for?(user)
    unread_messages_count_for(user).positive?
  end

  def mark_read_for!(user, at: Time.current)
    return unless buyer?(user) || seller?(user)

    update_column(last_read_column_for(user), at)
  end

  def self.unread_count_for(user)
    NegotiationMessage
      .joins(:negotiation)
      .merge(for_user(user))
      .where("negotiation_messages.user_id IS NULL OR negotiation_messages.user_id != :user_id", user_id: user.id)
      .where(
        "(negotiations.buyer_id = :user_id AND (negotiations.buyer_last_read_at IS NULL OR negotiation_messages.created_at > negotiations.buyer_last_read_at)) OR " \
        "(negotiations.seller_id = :user_id AND (negotiations.seller_last_read_at IS NULL OR negotiation_messages.created_at > negotiations.seller_last_read_at))",
        user_id: user.id
      )
      .count
  end

  def ensure_public_access_token!
    regenerate_public_access_token if public_access_token.blank?
    public_access_token
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

  def messages_unread_by(user)
    read_at = public_send(last_read_column_for(user))

    scope = negotiation_messages.reject { |message| message.user_id == user.id } if negotiation_messages.loaded?
    return scope.select { |message| read_at.blank? || message.created_at > read_at } if negotiation_messages.loaded?

    scope = negotiation_messages.where("user_id IS NULL OR user_id != ?", user.id)
    read_at.present? ? scope.where("created_at > ?", read_at) : scope
  end

  def last_read_column_for(user)
    buyer?(user) ? :buyer_last_read_at : :seller_last_read_at
  end
end

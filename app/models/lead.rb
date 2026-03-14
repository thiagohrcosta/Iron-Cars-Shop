class Lead < ApplicationRecord
  PIPELINE_STAGES = %w[new contacted negotiation won lost].freeze

  enum :status, { new: 0, contacted: 1, qualified: 2, lost: 3 }, prefix: true
  enum :source, { facebook_ads: 0, referral: 1, iron_cars_website: 2, agent_lead: 3 }

  belongs_to :matched_vehicle_listing, class_name: "VehicleListing", optional: true
  belongs_to :matched_seller, class_name: "User", optional: true

  has_many :negotiations, dependent: :nullify

  normalizes :email, with: ->(value) { value.to_s.strip.downcase.presence }
  normalizes :phone, with: ->(value) { value.to_s.strip.presence }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :interested_in, presence: true

  def interested_in=(value)
    super(Array(value).filter_map { |item| item.to_s.strip.presence }.uniq)
  end

  def distributed?
    distributed_at.present?
  end

  def latest_negotiation
    @latest_negotiation ||= negotiations.max_by(&:created_at)
  end

  def pipeline_stage
    return "won" if won?
    return "lost" if pipeline_lost?
    return "negotiation" if in_negotiation?
    return "contacted" if contacted_pipeline?

    "new"
  end

  def won?
    latest_negotiation&.accepted?
  end

  def pipeline_lost?
    return true if status_lost?

    latest_negotiation&.lost_for_lead_pipeline? || false
  end

  def in_negotiation?
    latest_negotiation&.seller_replied? || false
  end

  def contacted_pipeline?
    distributed? || status_contacted? || status_qualified?
  end
end

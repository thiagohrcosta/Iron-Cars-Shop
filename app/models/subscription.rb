class Subscription < ApplicationRecord
  belongs_to :user

  enum :plan, {
    iron_cars_pro: 0,
    iron_cars_premium: 1,
    iron_cars_premium_ai: 2
  }

  enum :status, {
    inactive: 0,
    trialing: 1,
    active: 2,
    past_due: 3,
    canceled: 4,
    unpaid: 5
  }

  validates :plan, :status, presence: true

  scope :currently_active, -> { where(status: %i[active trialing]).where("current_period_end IS NULL OR current_period_end >= ?", Time.current) }

  def active_access?
    (active? || trialing?) && (current_period_end.nil? || current_period_end >= Time.current)
  end

  def plan_label
    {
      "iron_cars_pro" => "Iron Cars Pro",
      "iron_cars_premium" => "Iron Cars Premium",
      "iron_cars_premium_ai" => "Iron Cars Premium AI"
    }.fetch(plan, "Iron Cars")
  end
end

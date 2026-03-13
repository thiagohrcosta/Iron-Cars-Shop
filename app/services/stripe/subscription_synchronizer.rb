module Billing
  class SubscriptionSynchronizer
    PLAN_BY_PRICE_LOOKUP_KEY = {
      "iron_cars_pro_monthly" => :iron_cars_pro,
      "iron_cars_premium_monthly" => :iron_cars_premium,
      "iron_cars_premium_ai_monthly" => :iron_cars_premium_ai
    }.freeze

    STATUS_MAP = {
      "trialing" => :trialing,
      "active" => :active,
      "past_due" => :past_due,
      "canceled" => :canceled,
      "unpaid" => :unpaid,
      "incomplete_expired" => :inactive,
      "incomplete" => :inactive
    }.freeze

    def self.sync_from_subscription!(user:, stripe_subscription:, price_lookup_key:)
      plan = PLAN_BY_PRICE_LOOKUP_KEY[price_lookup_key] || :iron_cars_pro

      subscription = user.subscription || user.build_subscription
      subscription.assign_attributes(
        plan: plan,
        status: STATUS_MAP.fetch(stripe_subscription.fetch("status"), :inactive),
        stripe_customer_id: stripe_subscription.fetch("customer"),
        stripe_subscription_id: stripe_subscription.fetch("id"),
        current_period_start: Time.zone.at(stripe_subscription.fetch("current_period_start")),
        current_period_end: Time.zone.at(stripe_subscription.fetch("current_period_end")),
        canceled_at: stripe_subscription["canceled_at"] ? Time.zone.at(stripe_subscription["canceled_at"]) : nil
      )
      subscription.save!
      subscription
    end

    def self.cancel_from_subscription!(stripe_subscription)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription["id"])
      return unless subscription

      subscription.update!(
        status: :canceled,
        canceled_at: stripe_subscription["canceled_at"] ? Time.zone.at(stripe_subscription["canceled_at"]) : Time.current,
        current_period_end: stripe_subscription["ended_at"] ? Time.zone.at(stripe_subscription["ended_at"]) : subscription.current_period_end
      )
    end
  end
end

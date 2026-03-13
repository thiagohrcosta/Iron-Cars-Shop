module Billing
  class SubscriptionSynchronizer
    STRIPE_STATUS_MAP = {
      "active"             => :active,
      "trialing"           => :trialing,
      "past_due"           => :past_due,
      "canceled"           => :canceled,
      "unpaid"             => :unpaid,
      "incomplete"         => :inactive,
      "incomplete_expired" => :inactive
    }.freeze

    def self.sync_from_stripe!(user:, stripe_subscription:, product_id:)
      plan = plan_for(product_id)
      unless plan
        Rails.logger.warn("SubscriptionSynchronizer: unknown product_id=#{product_id}")
        return
      end

      attrs = {
        plan:                   plan,
        status:                 STRIPE_STATUS_MAP.fetch(stripe_subscription["status"], :inactive),
        stripe_customer_id:     stripe_subscription["customer"],
        stripe_subscription_id: stripe_subscription["id"],
        current_period_start:   to_time(stripe_subscription["current_period_start"]),
        current_period_end:     to_time(stripe_subscription["current_period_end"]),
        canceled_at:            to_time(stripe_subscription["canceled_at"])
      }

      if user.subscription
        user.subscription.update!(attrs)
      else
        user.create_subscription!(attrs)
      end
    end

    def self.cancel_from_subscription!(stripe_subscription)
      sub = Subscription.find_by(stripe_subscription_id: stripe_subscription["id"])
      return unless sub

      sub.update!(
        status:      :canceled,
        canceled_at: to_time(stripe_subscription["canceled_at"])
      )
    end

    def self.plan_for(product_id)
      {
        ENV.fetch("STRIPE_PRODUCT_ID_PRO", nil)        => :iron_cars_pro,
        ENV.fetch("STRIPE_PRODUCT_ID_PREMIUM", nil)    => :iron_cars_premium,
        ENV.fetch("STRIPE_PRODUCT_ID_PREMIUM_AI", nil) => :iron_cars_premium_ai
      }[product_id]
    end

    def self.to_time(unix_timestamp)
      unix_timestamp ? Time.at(unix_timestamp) : nil
    end

    private_class_method :plan_for, :to_time
  end
end

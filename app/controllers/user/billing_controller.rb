class User::BillingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  PRICE_LOOKUP_KEY_BY_PLAN = {
    "iron_cars_pro" => "iron_cars_pro_monthly",
    "iron_cars_premium" => "iron_cars_premium_monthly",
    "iron_cars_premium_ai" => "iron_cars_premium_ai_monthly"
  }.freeze

  def create_checkout_session
    plan = params.require(:plan)
    lookup_key = PRICE_LOOKUP_KEY_BY_PLAN.fetch(plan)

    stripe = Billing::StripeClient.new
    customer_id = ensure_stripe_customer!(stripe)
    price = stripe.find_price_by_lookup_key(lookup_key)

    session = stripe.create_checkout_session(
      customer_id: customer_id,
      price_id: price.fetch("id"),
      success_url: user_analytics_url,
      cancel_url: user_analytics_url
    )

    redirect_to session.fetch("url"), allow_other_host: true
  rescue KeyError
    redirect_to user_analytics_path, alert: "Invalid plan selected."
  rescue Billing::StripeClient::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.class} - #{e.message}")
    redirect_to user_analytics_path, alert: "Unable to start checkout right now."
  end

  private

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end

  def ensure_stripe_customer!(stripe)
    return current_user.stripe_customer_id if current_user.stripe_customer_id.present?

    customer = stripe.create_customer(
      email: current_user.email,
      name: current_user.full_name,
      metadata: { user_id: current_user.id }
    )

    customer_id = customer.fetch("id")
    current_user.update!(stripe_customer_id: customer_id)
    customer_id
  end
end

class User::BillingController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  def product_id_by_plan
    {
      "iron_cars_pro"        => ENV.fetch("STRIPE_PRODUCT_ID_PRO"),
      "iron_cars_premium"    => ENV.fetch("STRIPE_PRODUCT_ID_PREMIUM"),
      "iron_cars_premium_ai" => ENV.fetch("STRIPE_PRODUCT_ID_PREMIUM_AI")
    }
  end

  def create_checkout_session
    plan = params.require(:plan)
    product_id = product_id_by_plan.fetch(plan)

    stripe = Billing::StripeClient.new
    customer_id = ensure_stripe_customer!(stripe)
    price = stripe.find_price_by_product(product_id)

    session = stripe.create_checkout_session(
      customer_id: customer_id,
      price_id: price.fetch("id"),
      success_url: user_analytics_url(subscribed: "1"),
      cancel_url: user_analytics_url
    )

    redirect_to session.fetch("url"), allow_other_host: true
  rescue KeyError
    redirect_to user_analytics_path, alert: "Invalid plan selected."
  rescue Billing::StripeClient::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.class} - #{e.message}")
    redirect_to user_analytics_path, alert: "Unable to start checkout right now. Please verify Stripe prices are configured."
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

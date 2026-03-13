class Webhooks::StripeController < ActionController::API
  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    stripe = Billing::StripeClient.new
    event = stripe.construct_webhook_event(payload: payload, signature: signature)

    case event.fetch("type")
    when "checkout.session.completed"
      handle_checkout_completed(stripe, event.fetch("data").fetch("object"))
    when "customer.subscription.updated", "customer.subscription.created"
      handle_subscription_sync(stripe, event.fetch("data").fetch("object"))
    when "customer.subscription.deleted"
      Billing::SubscriptionSynchronizer.cancel_from_subscription!(event.fetch("data").fetch("object"))
    end

    head :ok
  rescue Billing::StripeClient::StripeError, JSON::ParserError, KeyError => e
    Rails.logger.warn("Stripe webhook invalid payload: #{e.message}")
    head :bad_request
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("Stripe webhook user not found: #{e.message}")
    head :ok
  rescue StandardError => e
    Rails.logger.error("Stripe webhook error: #{e.class} - #{e.message}")
    head :internal_server_error
  end

  private

  def handle_checkout_completed(stripe, session)
    return unless session["mode"] == "subscription"

    stripe_subscription = stripe.retrieve_subscription(session.fetch("subscription"))
    handle_subscription_sync(stripe, stripe_subscription)
  end

  def handle_subscription_sync(stripe, stripe_subscription)
    customer_id = stripe_subscription.fetch("customer")
    user = User.find_by!(stripe_customer_id: customer_id)
    price_id = stripe_subscription.dig("items", "data", 0, "price", "id")
    price = stripe.retrieve_price(price_id)

    Billing::SubscriptionSynchronizer.sync_from_stripe!(
      user: user,
      stripe_subscription: stripe_subscription,
      product_id: price.fetch("product")
    )
  end
end

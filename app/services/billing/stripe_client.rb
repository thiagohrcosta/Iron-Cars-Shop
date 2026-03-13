require "net/http"
require "uri"
require "json"
require "openssl"

module Billing
  class StripeClient
    class StripeError < StandardError; end

    def initialize(secret_key: ENV["STRIPE_SECRET_KEY"])
      @secret_key = secret_key
    end

    def create_customer(email:, name:, metadata: {})
      post_form("/customers", {
        email: email,
        name: name,
        metadata: metadata
      })
    end

    def find_price_by_lookup_key(lookup_key)
      response = get("/prices", { lookup_keys: [ lookup_key ], active: true, limit: 1 })
      response.fetch("data").first
    end

    def create_checkout_session(customer_id:, price_id:, success_url:, cancel_url:)
      post_form("/checkout/sessions", {
        customer: customer_id,
        mode: "subscription",
        success_url: success_url,
        cancel_url: cancel_url,
        "line_items[0][price]" => price_id,
        "line_items[0][quantity]" => 1,
        allow_promotion_codes: true
      })
    end

    def retrieve_subscription(subscription_id)
      get("/subscriptions/#{subscription_id}")
    end

    def retrieve_price(price_id)
      get("/prices/#{price_id}")
    end

    def construct_webhook_event(payload:, signature:, webhook_secret: ENV["STRIPE_WEBHOOK_SECRET"])
      timestamp, signatures = parse_signature_header(signature)
      expected_signature = OpenSSL::HMAC.hexdigest("SHA256", webhook_secret, "#{timestamp}.#{payload}")

      unless signatures.any? { |entry| secure_compare(entry, expected_signature) }
        raise StripeError, "Invalid webhook signature"
      end

      JSON.parse(payload)
    end

    private

    attr_reader :secret_key

    def get(path, params = {})
      uri = URI.join(STRIPE_API_BASE_URL, path)
      uri.query = URI.encode_www_form(params) if params.present?
      perform_request(Net::HTTP::Get.new(uri))
    end

    def post_form(path, params)
      uri = URI.join(STRIPE_API_BASE_URL, path)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(params)
      perform_request(req)
    end

    def perform_request(request)
      request["Authorization"] = "Bearer #{secret_key}"
      request["Stripe-Version"] = STRIPE_API_VERSION

      response = Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      parsed = JSON.parse(response.body)
      raise StripeError, parsed["error"].to_s if response.code.to_i >= 400

      parsed
    rescue JSON::ParserError
      raise StripeError, "Unexpected Stripe response"
    end

    def parse_signature_header(signature)
      parts = signature.to_s.split(",").map { |entry| entry.split("=", 2) }.to_h
      timestamp = parts.fetch("t")
      signatures = signature.to_s.split(",").filter_map do |entry|
        key, value = entry.split("=", 2)
        value if key == "v1"
      end
      [ timestamp, signatures ]
    end

    def secure_compare(left, right)
      ActiveSupport::SecurityUtils.secure_compare(left, right)
    rescue ArgumentError
      false
    end
  end
end

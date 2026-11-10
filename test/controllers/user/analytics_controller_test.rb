require "test_helper"

class User::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller = create_user("seller@example.com", "Seller User")
    @car_model = create_car_model(@seller, body_type: :sedan)

    Subscription.create!(
      user: @seller,
      plan: :iron_cars_pro,
      status: :active,
      current_period_end: 2.months.from_now
    )

    @vehicle = create_vehicle(@seller, car_model: @car_model, price_cents: 4_500_000)

    @listing = VehicleListing.create!(
      vehicle: @vehicle,
      seller: @seller,
      status: :published,
      views_count: 30
    )
    @listing.mark_sold!(at: 10.days.ago)
  end

  test "returns analytics data json with selected range" do
    sign_in @seller

    get user_analytics_data_url, params: { range: "60d" }

    assert_response :success
    body = JSON.parse(response.body)

    assert_equal "60d", body["selected_range"]
    assert_equal 61, body["revenue_series"].size
    assert_equal 61, body["daily_sales_series"].size
    assert_equal 45_000.0, body.dig("stats", "revenue_last_30_days")
    assert_equal 1, body.dig("stats", "selected_range_sales")
  end

  test "renders the dashboard with the top vehicles for a subscriber" do
    sign_in @seller

    get user_analytics_url

    assert_response :success
    assert_includes response.body, @vehicle.full_name
  end

  test "forbids analytics data for user without subscription" do
    no_plan_user = create_user("noplan@example.com", "No Plan")

    sign_in no_plan_user

    get user_analytics_data_url

    assert_response :forbidden
  end

  test "a sale closed through an accepted offer counts today, at the agreed price" do
    buyer = create_user("analytics-buyer@example.com", "Analytics Buyer")
    vehicle = create_vehicle(@seller, car_model: @car_model, price_cents: 3_000_000)
    listing = VehicleListing.create!(vehicle: vehicle, seller: @seller, status: :published, published_at: 40.days.ago)
    negotiation = Negotiation.create!(
      vehicle_listing: listing, vehicle: vehicle, buyer: buyer, seller: @seller,
      price_cents: vehicle.price_cents, status: :pending
    )
    negotiation.submit_offer!(by: buyer, price_cents: 2_800_000)

    sign_in @seller
    post user_negotiation_acceptance_url(negotiation)

    listing.reload
    assert listing.sold?
    assert_in_delta Time.current, listing.sold_at, 5.seconds

    get user_analytics_data_url, params: { range: "30d" }

    assert_response :success
    body = JSON.parse(response.body)
    today = Date.current.iso8601

    assert_equal 28_000.0, body["revenue_series"].find { |point| point["date"] == today }["value"]
    assert_equal 1, body["daily_sales_series"].find { |point| point["date"] == today }["value"]
    assert_equal 28_000.0, body.dig("stats", "revenue_today")
    # Setup sale (listed $45,000, 10 days ago) + this one at the agreed $28,000, not the $30,000 asking price.
    assert_equal 73_000.0, body.dig("stats", "revenue_last_30_days")
  end
end

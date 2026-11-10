require "test_helper"

class User::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller = User.create!(
      email: "seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Seller User",
      document_id: "123456789",
      phone_number: "5551112222",
      address_street: "Main St",
      address_number: "10",
      address_neighborhood: "Downtown",
      address_city: "Austin",
      address_state: "TX",
      address_zip_code: "73301",
      address_country: "US"
    )


    @brand = Brand.create!(
      user: @seller,
      name: "BMW",
      slug: "bmw",
      description: "BMW",
      country: "Germany",
      founded_in: "1916"
    )
    @car_model = CarModel.create!(
      user: @seller,
      brand: @brand,
      name: "M3",
      slug: "m3",
      body_type: :sedan
    )

    Subscription.create!(
      user: @seller,
      plan: :iron_cars_pro,
      status: :active,
      current_period_end: 2.months.from_now
    )

    @vehicle = Vehicle.create!(
      user: @seller,
      car_model: @car_model,
      vin: "12345678901234567",
      year: 2023,
      mileage: 12_000,
      condition: :used,
      title_status: :clean,
      price_cents: 4_500_000,
      currency: :usd
    )

    @listing = VehicleListing.create!(
      vehicle: @vehicle,
      seller: @seller,
      status: :sold,
      views_count: 30,
      sold_at: 10.days.ago,
      expires_at: 20.days.from_now
    )
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

  test "forbids analytics data for user without subscription" do
    no_plan_user = User.create!(
      email: "noplan@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "No Plan",
      document_id: "987654321",
      phone_number: "5552223333",
      address_street: "Second St",
      address_number: "20",
      address_neighborhood: "Midtown",
      address_city: "Dallas",
      address_state: "TX",
      address_zip_code: "75001",
      address_country: "US"
    )

    sign_in no_plan_user

    get user_analytics_data_url

    assert_response :forbidden
  end

  test "a sale closed through accept_offer counts today, not when the SOLD badge expires" do
    buyer = User.create!(
      email: "analytics-buyer@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Analytics Buyer",
      document_id: "555666777",
      phone_number: "5554445555",
      address_street: "Third St",
      address_number: "30",
      address_neighborhood: "Uptown",
      address_city: "Austin",
      address_state: "TX",
      address_zip_code: "73301",
      address_country: "US"
    )
    vehicle = Vehicle.create!(
      user: @seller,
      car_model: @car_model,
      vin: "76543210987654321",
      year: 2024,
      mileage: 5_000,
      condition: :used,
      title_status: :clean,
      price_cents: 3_000_000,
      currency: :usd
    )
    listing = VehicleListing.create!(vehicle: vehicle, seller: @seller, status: :published, published_at: 40.days.ago)
    negotiation = Negotiation.create!(
      vehicle_listing: listing,
      vehicle: vehicle,
      buyer: buyer,
      seller: @seller,
      price_cents: vehicle.price_cents,
      status: :pending,
      accepted_by_buyer: true
    )

    sign_in @seller
    patch accept_offer_user_negotiation_url(negotiation)

    listing.reload
    assert listing.sold?
    assert_in_delta Time.current, listing.sold_at, 5.seconds
    assert_in_delta listing.sold_at + 30.days, listing.expires_at, 1.second

    get user_analytics_data_url, params: { range: "30d" }

    assert_response :success
    body = JSON.parse(response.body)
    today = body["revenue_series"].find { |point| point["date"] == Date.current.iso8601 }
    sales_today = body["daily_sales_series"].find { |point| point["date"] == Date.current.iso8601 }

    assert_equal 30_000.0, today["value"]
    assert_equal 1, sales_today["value"]
    assert_equal 30_000.0, body.dig("stats", "revenue_today")
    # Setup sale (10 days ago) + this one.
    assert_equal 75_000.0, body.dig("stats", "revenue_last_30_days")
  end
end

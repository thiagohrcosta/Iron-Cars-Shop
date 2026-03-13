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
      views_count: 30
    )
    @listing.update_column(:updated_at, 10.days.ago)
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
end

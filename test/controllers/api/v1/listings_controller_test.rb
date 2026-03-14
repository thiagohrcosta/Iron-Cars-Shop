require "test_helper"

class Api::V1::ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["INTERNAL_AI_API_TOKEN"]
    ENV["INTERNAL_AI_API_TOKEN"] = "test-internal-token"

    seller = User.create!(
      email: "api-seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "API Seller",
      document_id: "44556677889",
      phone_number: "5553334444",
      address_street: "Lexington Ave",
      address_number: "77",
      address_neighborhood: "Midtown",
      address_city: "New York",
      address_state: "NY",
      address_zip_code: "10019",
      address_country: "US"
    )

    brand = Brand.create!(
      user: seller,
      name: "BMW",
      slug: "bmw-api",
      description: "BMW brand",
      country: "Germany",
      founded_in: "1916"
    )

    car_model = CarModel.create!(
      user: seller,
      brand: brand,
      name: "M4",
      slug: "m4-api",
      description: "BMW M4",
      body_type: :coupe
    )

    vehicle = Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "12345678901234567",
      year: 2022,
      mileage: 14_000,
      exterior_color: "black",
      transmission: :automatic,
      fuel_type: :gasoline,
      drivetrain: :rwd,
      condition: :used,
      title_status: :clean,
      price_cents: 5_100_000,
      currency: :usd
    )

    VehicleListing.create!(
      vehicle: vehicle,
      seller: seller,
      status: :published
    )
  end

  teardown do
    ENV["INTERNAL_AI_API_TOKEN"] = @previous_token
  end

  test "rejects requests without token" do
    get api_v1_listings_url

    assert_response :unauthorized
  end

  test "returns listings for authenticated internal ai requests" do
    get api_v1_listings_url,
      params: { interested_in: [ "brand:BMW", "model:M4", "budget:50000", "city:New York" ] },
      headers: { "Authorization" => "Bearer test-internal-token" }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal 1, payload["total"]
    assert_equal "BMW", payload.dig("listings", 0, "brand")
  end
end

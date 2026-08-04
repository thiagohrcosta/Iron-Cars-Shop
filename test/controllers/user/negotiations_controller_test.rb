require "test_helper"

class User::NegotiationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @buyer = create_user("buyer-ctrl@example.com", "Buyer Ctrl")
    @seller = create_user("seller-ctrl@example.com", "Seller Ctrl")
    @vehicle = create_vehicle(@seller)
    @listing = VehicleListing.create!(vehicle: @vehicle, seller: @seller, status: :published)
    @negotiation = Negotiation.create!(
      vehicle_listing: @listing,
      vehicle: @vehicle,
      buyer: @buyer,
      seller: @seller,
      price_cents: @vehicle.price_cents,
      status: :pending
    )
    @negotiation.negotiation_messages.create!(user: @seller, content: "Still available?")
  end

  test "show marks the negotiation read for the current user" do
    sign_in @buyer

    assert @negotiation.unread_for?(@buyer)

    get user_negotiation_url(@negotiation)

    assert_response :success
    assert_not @negotiation.reload.unread_for?(@buyer)
  end

  test "index does not mark any negotiation read" do
    sign_in @buyer

    get user_negotiations_url

    assert_response :success
    assert @negotiation.reload.unread_for?(@buyer)
  end

  private

  def create_user(email, full_name)
    User.create!(
      email: email,
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: full_name,
      document_id: SecureRandom.random_number(10**11).to_s.rjust(11, "0"),
      phone_number: "5551212121",
      address_street: "Market St",
      address_number: "100",
      address_neighborhood: "Central",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US"
    )
  end

  def create_vehicle(seller)
    brand = Brand.create!(user: seller, name: "Ctrl BMW", slug: "ctrl-bmw", description: "BMW", country: "Germany", founded_in: "1916")
    car_model = CarModel.create!(user: seller, brand: brand, name: "Ctrl M4", slug: "ctrl-m4", description: "M4", body_type: :coupe)

    Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "#{SecureRandom.random_number(10**17).to_s.rjust(17, '0')}",
      year: 2024,
      mileage: 4_000,
      exterior_color: "black",
      transmission: :automatic,
      fuel_type: :gasoline,
      drivetrain: :rwd,
      condition: :used,
      title_status: :clean,
      price_cents: 5_800_000,
      currency: :usd
    )
  end
end

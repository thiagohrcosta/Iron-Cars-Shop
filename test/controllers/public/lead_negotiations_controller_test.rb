require "test_helper"

class Public::LeadNegotiationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seller = User.create!(
      email: "public-chat-seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Public Chat Seller",
      document_id: "11133355577",
      phone_number: "5557771111",
      address_street: "Market St",
      address_number: "50",
      address_neighborhood: "Center",
      address_city: "New York",
      address_state: "NY",
      address_zip_code: "10003",
      address_country: "US"
    )

    brand = Brand.create!(
      user: seller,
      name: "BMW",
      slug: "bmw-public-chat",
      description: "BMW",
      country: "Germany",
      founded_in: "1916"
    )

    car_model = CarModel.create!(
      user: seller,
      brand: brand,
      name: "3 Series",
      slug: "series-3-public-chat",
      description: "3 Series",
      body_type: :sedan
    )

    vehicle = Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "32145123451234512",
      year: 2025,
      mileage: 3_000,
      exterior_color: "black",
      transmission: :automatic,
      fuel_type: :gasoline,
      drivetrain: :rwd,
      condition: :used,
      title_status: :clean,
      price_cents: 4_618_005,
      currency: :usd
    )

    listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
    lead = Lead.create!(name: "John Stallone", email: "stallonejonny@email.com", interested_in: [ "brand:BMW" ], source: :agent_lead, status: :contacted)
    @negotiation = Negotiation.create!(vehicle_listing: listing, vehicle: vehicle, seller: seller, lead: lead, price_cents: vehicle.price_cents, status: :pending)
    @negotiation.ensure_public_access_token!
  end

  test "lead can open public conversation with token" do
    get public_lead_negotiation_url(token: @negotiation.public_access_token)

    assert_response :success
    assert_includes response.body, "Secure Lead Access"
  end

  test "lead can reply without login" do
    assert_difference("NegotiationMessage.count", 1) do
      post public_lead_negotiation_messages_url(token: @negotiation.public_access_token),
        params: { negotiation_message: { content: "I want to know more about this car." } }
    end

    assert_redirected_to public_lead_negotiation_url(token: @negotiation.public_access_token)
    assert_nil NegotiationMessage.order(:created_at).last.user_id
  end
end

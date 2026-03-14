require "test_helper"

class LeadTest < ActiveSupport::TestCase
  test "normalizes email and interested_in values" do
    lead = Lead.new(
      name: "Chris Doe",
      email: "  CHRIS@Example.COM ",
      interested_in: [ " Fiat ", "", "2025", "Fiat" ]
    )

    assert lead.valid?
    assert_equal "chris@example.com", lead.email
    assert_equal [ "Fiat", "2025" ], lead.interested_in
  end

  test "derives pipeline stage from negotiation lifecycle" do
    seller = User.create!(
      email: "lead-stage-seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Lead Stage Seller",
      document_id: "44411122233",
      phone_number: "5551212121",
      address_street: "Market St",
      address_number: "100",
      address_neighborhood: "Central",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US"
    )

    brand = Brand.create!(
      user: seller,
      name: "BMW",
      slug: "bmw-stage",
      description: "BMW",
      country: "Germany",
      founded_in: "1916"
    )

    car_model = CarModel.create!(
      user: seller,
      brand: brand,
      name: "M4",
      slug: "m4-stage",
      description: "M4",
      body_type: :coupe
    )

    vehicle = Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "11111234512345123",
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

    listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
    lead = Lead.create!(name: "Stage Lead", email: "stagelead@example.com", interested_in: [ "brand:BMW" ], source: :agent_lead, status: :new)

    assert_equal "new", lead.pipeline_stage

    lead.update!(distributed_at: Time.current, matched_vehicle_listing: listing, matched_seller: seller, status: :contacted)
    assert_equal "contacted", lead.pipeline_stage

    negotiation = Negotiation.create!(vehicle_listing: listing, vehicle: vehicle, seller: seller, lead: lead, price_cents: vehicle.price_cents, status: :pending)
    negotiation.negotiation_messages.create!(user: seller, content: "I can help with this vehicle.")
    assert_equal "negotiation", lead.reload.pipeline_stage

    negotiation.update!(status: :accepted, accepted_by_seller: true, accepted_at: Time.current)
    assert_equal "won", lead.reload.pipeline_stage
  end
end

require "test_helper"

class LeadNegotiationMailerTest < ActionMailer::TestCase
  test "sends seller message notification to the lead" do
    seller = User.create!(
      email: "seller-mail@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Seller Mail",
      document_id: "12312312312",
      phone_number: "5551110000",
      address_street: "Maple St",
      address_number: "12",
      address_neighborhood: "Center",
      address_city: "Austin",
      address_state: "TX",
      address_zip_code: "73301",
      address_country: "US"
    )

    brand = Brand.create!(
      user: seller,
      name: "BMW",
      slug: "bmw-mail",
      description: "BMW",
      country: "Germany",
      founded_in: "1916"
    )

    car_model = CarModel.create!(
      user: seller,
      brand: brand,
      name: "M4",
      slug: "m4-mail",
      description: "M4",
      body_type: :coupe
    )

    vehicle = Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "12345123451234512",
      year: 2023,
      mileage: 8_000,
      exterior_color: "black",
      transmission: :automatic,
      fuel_type: :gasoline,
      drivetrain: :rwd,
      condition: :used,
      title_status: :clean,
      price_cents: 6_200_000,
      currency: :usd
    )

    listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
    lead = Lead.create!(name: "John Lead", email: "johnlead@example.com", interested_in: [ "brand:BMW" ], source: :agent_lead, status: :contacted)
    negotiation = Negotiation.create!(vehicle_listing: listing, vehicle: vehicle, seller: seller, lead: lead, price_cents: vehicle.price_cents, status: :pending)
    message = negotiation.negotiation_messages.build(user: seller, content: "I can share more photos and details.")

    email = LeadNegotiationMailer.seller_message_notification(message)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "johnlead@example.com" ], email.to
    assert_includes email.subject, "responded"
  end
end

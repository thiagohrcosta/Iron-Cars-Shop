require "test_helper"

class LeadNegotiationLinkerTest < ActiveSupport::TestCase
  test "links open lead negotiations to user by email" do
    seller = User.create!(
      email: "seller-link@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Seller Link",
      document_id: "88811122233",
      phone_number: "5559090909",
      address_street: "Main St",
      address_number: "1",
      address_neighborhood: "Center",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US"
    )

    user = User.create!(
      email: "stallonejonny@email.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "John Stallone",
      document_id: "77711122233",
      phone_number: "5552020202",
      address_street: "Buyer Ave",
      address_number: "10",
      address_neighborhood: "North",
      address_city: "New York",
      address_state: "NY",
      address_zip_code: "10001",
      address_country: "US"
    )

    brand = Brand.create!(
      user: seller,
      name: "BMW",
      slug: "bmw-link",
      description: "BMW",
      country: "Germany",
      founded_in: "1916"
    )

    car_model = CarModel.create!(
      user: seller,
      brand: brand,
      name: "3 Series",
      slug: "series-3-link",
      description: "Series 3",
      body_type: :sedan
    )

    vehicle = Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: "99999123451234512",
      year: 2025,
      mileage: 5_000,
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
    lead = Lead.create!(
      name: "John Stallone",
      email: "stallonejonny@email.com",
      interested_in: [ "brand:BMW" ],
      source: :agent_lead,
      status: :contacted
    )

    negotiation = Negotiation.create!(
      vehicle_listing: listing,
      vehicle: vehicle,
      seller: seller,
      lead: lead,
      buyer: nil,
      price_cents: vehicle.price_cents,
      status: :pending
    )

    linked_count = LeadNegotiationLinker.new(user: user).call

    assert_equal 1, linked_count
    assert_equal user.id, negotiation.reload.buyer_id
  end
end

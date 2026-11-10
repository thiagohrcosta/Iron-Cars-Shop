require "test_helper"

class VehicleListingSoldTest < ActiveSupport::TestCase
  setup do
    @seller = User.create!(
      email: "sold-seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Sold Seller",
      document_id: "11122233344",
      phone_number: "5551212121",
      address_street: "Market St",
      address_number: "100",
      address_neighborhood: "Central",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US"
    )
    @buyer = User.create!(
      email: "sold-buyer@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Sold Buyer",
      document_id: "55566677788",
      phone_number: "5553434343",
      address_street: "Ocean Dr",
      address_number: "200",
      address_neighborhood: "Beach",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33139",
      address_country: "US"
    )
    brand = Brand.create!(user: @seller, name: "Audi", slug: "audi-sold", description: "Audi", country: "Germany", founded_in: "1909")
    car_model = CarModel.create!(user: @seller, brand: brand, name: "A4", slug: "a4-sold", description: "A4", body_type: :sedan)
    @vehicle = Vehicle.create!(
      user: @seller, car_model: car_model, vin: "22222333334444455", year: 2023, mileage: 9_000,
      condition: :used, title_status: :clean, price_cents: 3_500_000, currency: :usd
    )
    @listing = VehicleListing.create!(vehicle: @vehicle, seller: @seller, status: :published)
  end

  test "mark_sold! records when the deal closed and how long the SOLD badge shows" do
    sold_at = Time.zone.parse("2026-11-10 15:00")

    @listing.mark_sold!(at: sold_at)

    assert @listing.reload.sold?
    assert_equal sold_at, @listing.sold_at
    assert_equal sold_at + VehicleListing::SOLD_BADGE_DURATION, @listing.expires_at
  end

  test "accept! closes the negotiation and sells the listing with one timestamp" do
    negotiation = Negotiation.create!(
      vehicle_listing: @listing, vehicle: @vehicle, buyer: @buyer, seller: @seller,
      price_cents: @vehicle.price_cents, status: :pending, accepted_by_buyer: true
    )

    negotiation.accept!(by: @seller)

    assert negotiation.reload.accepted?
    assert negotiation.accepted_by_seller?
    assert_equal negotiation.accepted_at, @listing.reload.sold_at
    assert_equal "Offer accepted. Vehicle marked as SOLD for 30 days.", negotiation.negotiation_messages.last.content
  end
end

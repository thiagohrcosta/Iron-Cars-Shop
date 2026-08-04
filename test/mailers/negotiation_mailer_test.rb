require "test_helper"

class NegotiationMailerTest < ActionMailer::TestCase
  test "sends new message notification to the recipient" do
    buyer = create_user("buyer-notify@example.com", "Buyer Notify")
    seller = create_user("seller-notify@example.com", "Seller Notify")
    vehicle = create_vehicle(seller)
    listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
    negotiation = Negotiation.create!(
      vehicle_listing: listing,
      vehicle: vehicle,
      buyer: buyer,
      seller: seller,
      price_cents: vehicle.price_cents,
      status: :pending
    )
    message = negotiation.negotiation_messages.build(user: seller, content: "Can I share more photos?")

    email = NegotiationMailer.new_message_notification(message, buyer)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "buyer-notify@example.com" ], email.to
    assert_includes email.subject, "New message"
    assert_includes email.text_part.body.to_s, "Can I share more photos?"
    assert_includes email.html_part.body.to_s, "Can I share more photos?"
  end

  test "falls back to email when sender has no full name" do
    buyer = create_user("buyer-fallback@example.com", "Buyer Fallback")
    seller = create_user("seller-fallback@example.com", "")
    vehicle = create_vehicle(seller)
    listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
    negotiation = Negotiation.create!(
      vehicle_listing: listing,
      vehicle: vehicle,
      buyer: buyer,
      seller: seller,
      price_cents: vehicle.price_cents,
      status: :pending
    )
    message = negotiation.negotiation_messages.build(user: seller, content: "Hello there")

    email = NegotiationMailer.new_message_notification(message, buyer)

    assert_includes email.html_part.body.to_s, "seller-fallback@example.com"
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
    brand = Brand.create!(user: seller, name: "Mail BMW #{SecureRandom.hex(4)}", slug: "mail-bmw-#{SecureRandom.hex(4)}", description: "BMW", country: "Germany", founded_in: "1916")
    car_model = CarModel.create!(user: seller, brand: brand, name: "Mail M4", slug: "mail-m4-#{SecureRandom.hex(4)}", description: "M4", body_type: :coupe)

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

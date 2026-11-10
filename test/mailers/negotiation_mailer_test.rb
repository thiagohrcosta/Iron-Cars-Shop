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
    seller = create_user("seller-fallback@example.com", "Seller Fallback")
    # User validates full_name presence; simulate a legacy record with a blank name.
    seller.update_column(:full_name, "")
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
end

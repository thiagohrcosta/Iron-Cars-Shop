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

end

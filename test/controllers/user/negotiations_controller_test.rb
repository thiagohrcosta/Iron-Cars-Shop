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

  test "create opens a negotiation at the asking price with the vehicle summary" do
    other_vehicle = create_vehicle(@seller, price_cents: 4_200_000, mileage: 12_345)
    other_listing = VehicleListing.create!(vehicle: other_vehicle, seller: @seller, status: :published)
    sign_in @buyer

    assert_difference("Negotiation.count", 1) do
      post user_negotiations_url, params: { negotiation: { vehicle_listing_id: other_listing.id } }
    end

    negotiation = Negotiation.order(:created_at).last
    assert_redirected_to user_negotiation_url(negotiation)
    assert_equal [ @buyer, @seller, 4_200_000 ], [ negotiation.buyer, negotiation.seller, negotiation.price_cents.to_i ]
    assert_match(/\AVehicle information: .+ Listed price \$42,000\. 12,345 miles/, negotiation.negotiation_messages.sole.content)
  end

  test "create refuses a negotiation on your own vehicle" do
    sign_in @seller

    assert_no_difference("Negotiation.count") do
      post user_negotiations_url, params: { negotiation: { vehicle_listing_id: @listing.id } }
    end

    assert_redirected_to car_url(@vehicle)
    assert_equal "You cannot negotiate your own vehicle.", flash[:alert]
  end
end

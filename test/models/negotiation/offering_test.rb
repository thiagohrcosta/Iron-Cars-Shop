require "test_helper"

class Negotiation::OfferingTest < ActiveSupport::TestCase
  setup do
    @seller = create_user("offering-seller@example.com", "Offering Seller")
    @buyer = create_user("offering-buyer@example.com", "Offering Buyer")
    @vehicle = create_vehicle(@seller, price_cents: 3_500_000)
    @listing = VehicleListing.create!(vehicle: @vehicle, seller: @seller, status: :published)
    @negotiation = Negotiation.create!(
      vehicle_listing: @listing, vehicle: @vehicle, buyer: @buyer, seller: @seller,
      price_cents: @vehicle.price_cents, status: :pending
    )
  end

  test "submit_offer! records the buyer's offer and posts it in the thread" do
    @negotiation.submit_offer!(by: @buyer, price_cents: 3_200_000)

    assert @negotiation.reload.offer_active?
    assert_equal 3_200_000, @negotiation.price_cents
    assert_equal "Offer submitted: $32,000", @negotiation.negotiation_messages.last.content
    assert_equal 1, @negotiation.offer_attempts_count
  end

  test "submit_offer! refuses the seller, a non-positive amount, and a second offer while one is pending" do
    assert_raises(Negotiation::InvalidTransition) { @negotiation.submit_offer!(by: @seller, price_cents: 3_200_000) }
    assert_raises(Negotiation::InvalidTransition) { @negotiation.submit_offer!(by: @buyer, price_cents: 0) }

    @negotiation.submit_offer!(by: @buyer, price_cents: 3_200_000)
    assert_raises(Negotiation::InvalidTransition) { @negotiation.submit_offer!(by: @buyer, price_cents: 3_300_000) }
  end

  test "accept! sells the listing at the agreed price with one timestamp" do
    @negotiation.submit_offer!(by: @buyer, price_cents: 3_200_000)
    at = Time.zone.parse("2026-11-10 15:00")

    @negotiation.accept!(by: @seller, at: at)

    assert @negotiation.reload.accepted?
    assert_equal at, @negotiation.accepted_at
    @listing.reload
    assert @listing.sold?
    assert_equal at, @listing.sold_at
    assert_equal 3_200_000, @listing.sold_price_cents
    assert_equal at + VehicleListing::SOLD_BADGE_DURATION, @listing.expires_at
    assert_equal "Offer accepted. Vehicle marked as SOLD for 30 days.", @negotiation.negotiation_messages.last.content
  end

  test "accept! and reject! refuse without an active offer or when called by the buyer" do
    assert_raises(Negotiation::InvalidTransition) { @negotiation.accept!(by: @seller) }
    assert_raises(Negotiation::InvalidTransition) { @negotiation.reject!(by: @seller) }

    @negotiation.submit_offer!(by: @buyer, price_cents: 3_200_000)
    assert_raises(Negotiation::InvalidTransition) { @negotiation.accept!(by: @buyer) }
    assert_raises(Negotiation::InvalidTransition) { @negotiation.reject!(by: @buyer) }
    assert_not @listing.reload.sold?
  end

  test "reject! tells the buyer how many offers remain, then closes at the limit" do
    @negotiation.submit_offer!(by: @buyer, price_cents: 3_000_000)
    @negotiation.reject!(by: @seller)
    assert_equal "Offer rejected. Buyer still has 2 more attempts.", @negotiation.negotiation_messages.last.content

    @negotiation.submit_offer!(by: @buyer, price_cents: 3_100_000)
    @negotiation.reject!(by: @seller)
    assert_equal "Offer rejected. Buyer still has 1 more attempt.", @negotiation.negotiation_messages.last.content

    @negotiation.submit_offer!(by: @buyer, price_cents: 3_200_000)
    @negotiation.reject!(by: @seller)
    assert_equal "Offer rejected. Negotiation closed after reaching the maximum number of offers.", @negotiation.negotiation_messages.last.content
    assert @negotiation.offer_limit_reached?
    assert_raises(Negotiation::InvalidTransition) { @negotiation.submit_offer!(by: @buyer, price_cents: 3_300_000) }
  end
end

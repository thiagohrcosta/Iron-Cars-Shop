require "test_helper"

class User::Negotiations::OfferLifecycleControllersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seller = create_user("lifecycle-seller@example.com", "Lifecycle Seller")
    @buyer = create_user("lifecycle-buyer@example.com", "Lifecycle Buyer")
    @outsider = create_user("lifecycle-outsider@example.com", "Lifecycle Outsider")
    @vehicle = create_vehicle(@seller, price_cents: 3_500_000)
    @listing = VehicleListing.create!(vehicle: @vehicle, seller: @seller, status: :published)
    @negotiation = Negotiation.create!(
      vehicle_listing: @listing, vehicle: @vehicle, buyer: @buyer, seller: @seller,
      price_cents: @vehicle.price_cents, status: :pending
    )
  end

  test "buyer makes an offer, seller accepts it" do
    sign_in @buyer
    post user_negotiation_offer_url(@negotiation), params: { offer_price: "32,000" }
    assert_redirected_to user_negotiation_url(@negotiation)
    assert_equal 3_200_000, @negotiation.reload.price_cents
    assert @negotiation.offer_active?

    sign_in @seller
    post user_negotiation_acceptance_url(@negotiation)
    assert_redirected_to user_negotiation_url(@negotiation)
    assert_equal "Offer accepted successfully.", flash[:notice]
    assert @negotiation.reload.accepted?
    assert_equal 3_200_000, @listing.reload.sold_price_cents
  end

  test "offer amounts are read as dollars with commas as thousands separators" do
    sign_in @buyer
    post user_negotiation_offer_url(@negotiation), params: { offer_price: "$31,500.50" }

    assert_equal 3_150_050, @negotiation.reload.price_cents
  end

  # Regression: step=100 with min=1 made the browser reject round offers like 25000 and
  # the listed price the field is prefilled with, so buyers could not submit an offer.
  test "the offer field accepts any dollar amount" do
    sign_in @buyer
    get user_negotiation_url(@negotiation)

    assert_select "input.offer-price-input[step=any][min='1']"
  end

  test "seller rejects an offer" do
    @negotiation.submit_offer!(by: @buyer, price_cents: 3_000_000)

    sign_in @seller
    post user_negotiation_rejection_url(@negotiation)

    assert_redirected_to user_negotiation_url(@negotiation)
    assert @negotiation.reload.rejected?
  end

  test "a refused transition redirects back with the reason" do
    sign_in @seller
    post user_negotiation_acceptance_url(@negotiation)

    assert_redirected_to user_negotiation_url(@negotiation)
    assert_equal "There is no pending offer to accept.", flash[:alert]
    assert_not @listing.reload.sold?
  end

  # Security regression guard (#58): a user who is neither buyer nor seller must get a 404,
  # never a redirect or a page that leaks the negotiation.
  test "non-participants get 404 on every offer action" do
    @negotiation.submit_offer!(by: @buyer, price_cents: 3_000_000)

    [ user_negotiation_offer_url(@negotiation), user_negotiation_acceptance_url(@negotiation),
      user_negotiation_rejection_url(@negotiation) ].each do |url|
      sign_in @outsider # a request that ends in 404 does not persist the test sign-in
      post url, params: { offer_price: "1" }
      assert_response :not_found, "expected 404 for #{url}"
    end

    assert @negotiation.reload.offer_active?
  end
end

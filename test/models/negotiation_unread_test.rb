require "test_helper"

class NegotiationUnreadTest < ActiveSupport::TestCase
  setup do
    @buyer = create_user("buyer-unread@example.com", "Buyer Unread")
    @seller = create_user("seller-unread@example.com", "Seller Unread")
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
  end

  test "counts only counterpart messages created after participant last read time" do
    @negotiation.mark_read_for!(@buyer, at: 5.minutes.ago)

    @negotiation.negotiation_messages.create!(user: @buyer, content: "I am interested.")
    @negotiation.negotiation_messages.create!(user: @seller, content: "This is still available.")

    assert_equal 1, @negotiation.unread_messages_count_for(@buyer)
    assert_equal 1, Negotiation.unread_count_for(@buyer)
    assert_equal 1, @negotiation.unread_messages_count_for(@seller)
  end

  test "signed in participant message notifications are throttled" do
    assert_emails 1 do
      @negotiation.negotiation_messages.create!(user: @seller, content: "First reply")
    end

    assert_emails 0 do
      @negotiation.negotiation_messages.create!(user: @seller, content: "Second quick reply")
    end

    @negotiation.update!(buyer_last_notified_at: 31.minutes.ago)

    assert_emails 1 do
      @negotiation.negotiation_messages.create!(user: @seller, content: "Follow up later")
    end
  end

  test "marking a negotiation read clears unread messages for that participant" do
    @negotiation.negotiation_messages.create!(user: @seller, content: "Can I help?")

    assert @negotiation.unread_for?(@buyer)

    @negotiation.mark_read_for!(@buyer)

    assert_not @negotiation.reload.unread_for?(@buyer)
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
    brand = Brand.create!(user: seller, name: "Unread BMW", slug: "unread-bmw", description: "BMW", country: "Germany", founded_in: "1916")
    car_model = CarModel.create!(user: seller, brand: brand, name: "Unread M4", slug: "unread-m4", description: "M4", body_type: :coupe)

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

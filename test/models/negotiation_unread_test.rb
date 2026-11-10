require "test_helper"

class NegotiationUnreadTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

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

  test "class-level unread_count_for sums unread messages across negotiations in a single query" do
    other_seller = create_user("seller-unread-2@example.com", "Seller Unread 2")
    other_vehicle = create_vehicle(other_seller)
    other_listing = VehicleListing.create!(vehicle: other_vehicle, seller: other_seller, status: :published)
    other_negotiation = Negotiation.create!(
      vehicle_listing: other_listing,
      vehicle: other_vehicle,
      buyer: @buyer,
      seller: other_seller,
      price_cents: other_vehicle.price_cents,
      status: :pending
    )

    @negotiation.negotiation_messages.create!(user: @seller, content: "Message one")
    @negotiation.negotiation_messages.create!(user: @seller, content: "Message two")
    other_negotiation.negotiation_messages.create!(user: other_seller, content: "Message three")

    query_count = count_queries { Negotiation.unread_count_for(@buyer) }

    assert_equal 1, query_count
    assert_equal 3, Negotiation.unread_count_for(@buyer)
  end

  test "signed in participant message notifications are throttled" do
    assert_emails 1 do
      perform_enqueued_jobs do
        @negotiation.negotiation_messages.create!(user: @seller, content: "First reply")
      end
    end

    assert_emails 0 do
      perform_enqueued_jobs do
        @negotiation.negotiation_messages.create!(user: @seller, content: "Second quick reply")
      end
    end

    @negotiation.update!(buyer_last_notified_at: 31.minutes.ago)

    assert_emails 1 do
      perform_enqueued_jobs do
        @negotiation.negotiation_messages.create!(user: @seller, content: "Follow up later")
      end
    end
  end

  test "marking a negotiation read clears unread messages for that participant" do
    @negotiation.negotiation_messages.create!(user: @seller, content: "Can I help?")

    assert @negotiation.unread_for?(@buyer)

    @negotiation.mark_read_for!(@buyer)

    assert_not @negotiation.reload.unread_for?(@buyer)
  end

  private

  def count_queries(&block)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:sql].match?(/\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/) }

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end

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

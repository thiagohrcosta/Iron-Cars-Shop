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
end

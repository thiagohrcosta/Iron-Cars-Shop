require "test_helper"

class SellerReportTest < ActiveSupport::TestCase
  setup do
    @seller = create_user("report-seller@example.com", "Report Seller")
    @other_seller = create_user("report-other@example.com", "Other Seller")
  end

  test "counts each sale on the day it closed, at the price it closed for" do
    travel_to Time.zone.parse("2026-11-10 12:00") do
      sell(price_cents: 5_000_000, sold_for: 4_500_000, at: 10.days.ago)
      sell(price_cents: 3_000_000, sold_for: 3_000_000, at: Time.current)
      sell(price_cents: 9_000_000, sold_for: 9_000_000, at: 40.days.ago)
      sell(price_cents: 7_000_000, sold_for: 7_000_000, at: Time.current, seller: @other_seller)

      report = SellerReport.new(seller: @seller, days: 30)
      revenue = report.revenue_series.to_h { |point| [ point[:date], point[:value] ] }
      sales = report.daily_sales_series.to_h { |point| [ point[:date], point[:value] ] }

      assert_equal 31, report.revenue_series.size
      assert_equal 45_000.0, revenue["2026-10-31"]
      assert_equal 30_000.0, revenue["2026-11-10"]
      assert_equal 1, sales["2026-11-10"]
      assert_equal 30_000.0, report.stats[:revenue_today]
      assert_equal 75_000.0, report.stats[:revenue_last_30_days]
      assert_equal 75_000.0, report.stats[:selected_range_revenue]
      assert_equal 1, report.stats[:sold_cars] # this month
      assert_equal 55_000.0, report.stats[:avg_ticket] # (45k + 30k + 90k) / 3
    end
  end

  test "groups sales by the app's local day, not the database's UTC day" do
    Time.use_zone("America/Los_Angeles") do
      travel_to Time.zone.parse("2026-11-10 12:00") do
        # 2026-11-10 06:00 UTC is still Nov 9 in Los Angeles.
        sell(price_cents: 2_000_000, sold_for: 2_000_000, at: Time.utc(2026, 11, 10, 6))

        revenue = SellerReport.new(seller: @seller, days: 30).revenue_series.to_h { |point| [ point[:date], point[:value] ] }

        assert_equal 20_000.0, revenue["2026-11-09"]
        assert_equal 0.0, revenue["2026-11-10"]
      end
    end
  end

  test "lists the most viewed vehicles first, including ones without a listing" do
    popular = create_vehicle(@seller)
    VehicleListing.create!(vehicle: popular, seller: @seller, status: :published, views_count: 50)
    unlisted = create_vehicle(@seller)

    assert_equal [ popular, unlisted ], SellerReport.new(seller: @seller, days: 30).top_vehicles.to_a
  end

  private

  def sell(price_cents:, sold_for:, at:, seller: @seller)
    vehicle = create_vehicle(seller, price_cents: price_cents)
    VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published).mark_sold!(at: at, price_cents: sold_for)
  end
end

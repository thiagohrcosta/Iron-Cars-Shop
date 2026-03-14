require "test_helper"

class PublicListingSearchTest < ActiveSupport::TestCase
  test "uses an order clause compatible with the listing table schema" do
    sql = PublicListingSearch.new.results.to_sql

    refute_includes sql, "#{VehicleListing.table_name}.updated_at"
    assert_includes sql, "#{VehicleListing.table_name}.published_at DESC"
  end

  test "can execute the search without referencing missing timestamp columns" do
    assert_nothing_raised do
      PublicListingSearch.new.results.limit(1).load
    end
  end
end

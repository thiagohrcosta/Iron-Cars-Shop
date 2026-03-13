class AddVehicleListingToNegotiation < ActiveRecord::Migration[8.0]
  def change
    add_reference :negotiations, :vehicle_listing, null: false, foreign_key: { to_table: :veihcle_listings }
  end
end

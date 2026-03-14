class AddDistributionFieldsToLeadsAndNegotiations < ActiveRecord::Migration[8.0]
  def change
    add_reference :leads, :matched_vehicle_listing, foreign_key: { to_table: :veihcle_listings }
    add_reference :leads, :matched_seller, foreign_key: { to_table: :users }
    add_column :leads, :distributed_at, :datetime

    change_column_null :negotiations, :buyer_id, true
    add_reference :negotiations, :lead, foreign_key: true
  end
end

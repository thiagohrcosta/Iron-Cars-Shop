class AddReadTimestampsToNegotiations < ActiveRecord::Migration[8.0]
  def change
    add_column :negotiations, :buyer_last_read_at, :datetime
    add_column :negotiations, :seller_last_read_at, :datetime
    add_column :negotiations, :buyer_last_notified_at, :datetime
    add_column :negotiations, :seller_last_notified_at, :datetime
  end
end

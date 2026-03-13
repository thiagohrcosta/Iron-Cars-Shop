class CreateVehicleListings < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_listings do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "draft"
      t.datetime :published_at
      t.datetime :expires_at
      t.integer :views_count, default: 0, null: false
      t.boolean :featured, default: false, null: false
    end
  end
end

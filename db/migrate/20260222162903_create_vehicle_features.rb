class CreateVehicleFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_features do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :name,        null: false
      t.string :category

      t.timestamps
    end

    add_index :vehicle_features, [ :vehicle_id, :name ], unique: true
  end
end

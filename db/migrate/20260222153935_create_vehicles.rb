class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      # Core
      t.string :vin,                  null: false
      t.references :car_model,         null: false, foreign_key: true
      t.integer :year,                 null: false
      t.integer :mileage,              null: false, default: 0

      # Appearance
      t.string  :exterior_color
      t.string  :interior_color

      # Mechanical
      t.string  :transmission
      t.string  :fuel_type
      t.string  :drivetrain
      t.string  :engine_description

      # Efficiency
      t.integer :mpg_city
      t.integer :mpg_highway

      # Physical history
      t.integer :owners_count,         default: 0
      t.integer :accident_count,       default: 0
      t.boolean :salvage_title,        default: false, null: false
      t.boolean :flood_damage,         default: false, null: false
      t.boolean :frame_damage,         default: false, null: false
      t.boolean :lemon_history,        default: false, null: false

      # American title status
      t.string  :title_status,         default: "clean", null: false

      # Details
      t.integer :doors
      t.integer :seats
      t.string  :condition,            null: false

      # Pricing
      t.integer :price_cents,          null: false, default: 0
      t.integer :currency,             null: false, default: 0

      t.references :user,              null: false, foreign_key: true

      t.timestamps
    end

    add_index :vehicles, :vin,          unique: true
    add_index :vehicles, :year
    add_index :vehicles, :condition
    add_index :vehicles, :title_status
    add_index :vehicles, :price_cents
    add_index :vehicles, :mileage
  end
end

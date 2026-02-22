class CreateCarModels < ActiveRecord::Migration[8.0]
  def change
    create_table :car_models do |t|
      t.string  :name,                  null: false
      t.string  :slug,                  null: false
      t.string  :description
      t.integer :body_type,             null: false
      t.date    :production_start_date
      t.date    :production_end_date
      t.boolean :active,                default: true

      t.references :brand, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.timestamps
    end

    add_index :car_models, :slug, unique: true

    add_index :car_models, [ :brand_id, :name ], unique: true

    add_index :car_models, :brand_id,
              where: "active = true",
              name: "index_car_models_on_brand_id_active"
  end
end

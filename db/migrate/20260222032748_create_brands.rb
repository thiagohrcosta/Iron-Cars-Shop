class CreateBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :brands do |t|
      t.timestamps

      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :country, null: false
      t.string :founded_in, null: false
      t.boolean :active, null: false, default: true

      t.reference :user, null: false, foreign_key: true
    end
  end
end

class CreateBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :brands do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.text    :description
      t.string  :country,     null: false
      t.integer :founded_in,  null: false   # era string, faz mais sentido como integer (ex: 1903)
      t.boolean :active,      null: false, default: true

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :brands, :slug,  unique: true

    add_index :brands, :name,  unique: true
  end
end

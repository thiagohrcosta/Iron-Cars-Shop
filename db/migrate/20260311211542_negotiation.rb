class Negotiation < ActiveRecord::Migration[8.0]
  def change
    create_table :negotiations do |t|
    t.decimal :price_cents, null: false, precision: 10, scale: 2
    t.string :status, null: false, default: 'pending'

    t.boolean :accepted_by_seller, default: false
    t.boolean :accepted_by_buyer, default: false

    t.datetime :accepted_at
    t.datetime :rejected_at

    t.references :seller, null: false, foreign_key: { to_table: :users }
    t.references :buyer, null: false, foreign_key: { to_table: :users }
    t.references :vehicle, null: false, foreign_key: true
    t.timestamps
    end
  end
end

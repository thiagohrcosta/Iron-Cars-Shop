class NegotiationMessage < ActiveRecord::Migration[8.0]
  def change
    create_table :negotiation_messages do |t|
      t.references :negotiation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end

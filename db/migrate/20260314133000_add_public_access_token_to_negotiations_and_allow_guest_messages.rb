class AddPublicAccessTokenToNegotiationsAndAllowGuestMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :negotiations, :public_access_token, :string
    add_index :negotiations, :public_access_token, unique: true

    change_column_null :negotiation_messages, :user_id, true
  end
end

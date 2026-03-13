class AddSubscriptionAndStripeFields < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :plan, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :canceled_at
      t.timestamps
    end

    add_index :subscriptions, :stripe_customer_id, unique: true
    add_index :subscriptions, :stripe_subscription_id, unique: true

    add_column :users, :stripe_customer_id, :string
    add_index :users, :stripe_customer_id, unique: true
  end
end

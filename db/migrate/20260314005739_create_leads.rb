class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.integer :status, null: false, default: 0
      t.integer :source, null: false, default: 0
      t.string :interested_in
      t.timestamps
    end
  end
end

class ChangeInterestedInToJsonbOnLeads < ActiveRecord::Migration[8.0]
  def up
    change_column :leads,
      :interested_in,
      :jsonb,
      default: [],
      null: false,
      using: <<~SQL.squish
        CASE
          WHEN interested_in IS NULL OR btrim(interested_in) = '' THEN '[]'::jsonb
          ELSE to_jsonb(ARRAY[interested_in])
        END
      SQL

    add_index :leads, :email
  end

  def down
    remove_index :leads, :email if index_exists?(:leads, :email)

    change_column :leads,
      :interested_in,
      :string,
      using: <<~SQL.squish
        CASE
          WHEN jsonb_array_length(interested_in) = 0 THEN NULL
          ELSE interested_in ->> 0
        END
      SQL
  end
end

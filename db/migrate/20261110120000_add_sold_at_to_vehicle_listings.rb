class AddSoldAtToVehicleListings < ActiveRecord::Migration[8.1]
  # The table is still misspelled (see #50); update this name if it is renamed first.
  TABLE = :veihcle_listings

  def up
    add_column TABLE, :sold_at, :datetime

    # Backfill already-sold listings, best source first:
    #   1. when the seller accepted the offer (latest accepted negotiation),
    #   2. expires_at - 30 days (accept_offer sets expires_at = sold time + 30 days),
    #   3. published_at.
    execute <<~SQL
      UPDATE #{TABLE} AS listings
      SET sold_at = COALESCE(
        (SELECT MAX(negotiations.accepted_at)
           FROM negotiations
          WHERE negotiations.vehicle_listing_id = listings.id
            AND negotiations.status = 'accepted'),
        listings.expires_at - INTERVAL '30 days',
        listings.published_at
      )
      WHERE listings.status = 'sold'
    SQL
  end

  def down
    remove_column TABLE, :sold_at
  end
end

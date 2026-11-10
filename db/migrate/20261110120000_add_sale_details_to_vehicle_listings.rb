class AddSaleDetailsToVehicleListings < ActiveRecord::Migration[8.1]
  # The table is still misspelled (see #50); update this name if it is renamed first.
  TABLE = :veihcle_listings

  def up
    add_column TABLE, :sold_at, :datetime
    add_column TABLE, :sold_price_cents, :bigint
    add_index TABLE, [ :seller_id, :sold_at ]

    # Backfill already-sold listings from the best source available:
    #   sold_at:          latest accepted negotiation, else expires_at - 30 days
    #                     (accept_offer set expires_at = sale + 30 days), else published_at.
    #   sold_price_cents: that negotiation's agreed price, else the vehicle's listed price.
    execute <<~SQL
      UPDATE #{TABLE} AS listings
      SET sold_at = COALESCE(sale.accepted_at, listings.expires_at - INTERVAL '30 days', listings.published_at),
          sold_price_cents = COALESCE(ROUND(sale.agreed_price_cents)::bigint, sale.listed_price_cents)
      FROM (
        SELECT sold.id AS listing_id,
               vehicles.price_cents AS listed_price_cents,
               accepted.accepted_at,
               accepted.price_cents AS agreed_price_cents
          FROM #{TABLE} AS sold
          JOIN vehicles ON vehicles.id = sold.vehicle_id
          LEFT JOIN LATERAL (
            SELECT negotiations.accepted_at, negotiations.price_cents
              FROM negotiations
             WHERE negotiations.vehicle_listing_id = sold.id
               AND negotiations.status = 'accepted'
             ORDER BY negotiations.accepted_at DESC NULLS LAST
             LIMIT 1
          ) AS accepted ON TRUE
         WHERE sold.status = 'sold'
      ) AS sale
      WHERE listings.id = sale.listing_id
    SQL
  end

  def down
    remove_index TABLE, [ :seller_id, :sold_at ]
    remove_column TABLE, :sold_price_cents
    remove_column TABLE, :sold_at
  end
end

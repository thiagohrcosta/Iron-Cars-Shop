class VehicleListing < ApplicationRecord
  self.table_name = if connection.data_source_exists?("vehicle_listings")
    "vehicle_listings"
  else
    "veihcle_listings"
  end

  belongs_to :vehicle
  belongs_to :seller, class_name: "User"

  enum :status, { draft: "draft", published: "published", expired: "expired", blocked: "blocked", removed: "removed", sold: "sold" }

  validates :status, presence: true

  def sold_visible?
    sold? && expires_at.present? && expires_at >= Time.current
  end
end

# # Backward-compatible alias for legacy misspelled references still present in the app.
# VeihcleListing = VehicleListing unless defined?(VeihcleListing)

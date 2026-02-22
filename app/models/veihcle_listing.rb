class VeihcleListing < ApplicationRecord
  belongs_to :vehicle
  belongs_to :seller, class_name: "User"

  enum status: { draft: "draft", published: "published", expired: "expired", blocked: "blocked", removed: "removed" }

  validates :status, presence: true
end

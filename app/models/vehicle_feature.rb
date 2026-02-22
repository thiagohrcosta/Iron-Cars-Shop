class VehicleFeature < ApplicationRecord
  belongs_to :vehicle

  CATEGORIES = %w[safety comfort technology exterior performance packages].freeze

  validates :name,     presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
  validates :name,     uniqueness: { scope: :vehicle_id, case_sensitive: false }

  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_name,     ->(name) { where("lower(name) = ?", name.downcase) }
end

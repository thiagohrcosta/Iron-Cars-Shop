class Vehicle < ApplicationRecord
  belongs_to :car_model
  belongs_to :user

  has_one  :veihcle_listing,  dependent: :destroy
  has_many :vehicle_features, dependent: :destroy
  has_many_attached :photos

  enum :transmission, {
    automatic:    "automatic",
    manual:       "manual",
    cvt:          "cvt",
    semi_auto:    "semi_auto"
  }, prefix: true

  enum :fuel_type, {
    gasoline:     "gasoline",
    diesel:       "diesel",
    hybrid:       "hybrid",
    plug_in_hybrid: "plug_in_hybrid",
    electric:     "electric",
    hydrogen:     "hydrogen"
  }, prefix: true

  enum :drivetrain, {
    fwd:          "fwd",   # Front-Wheel Drive
    rwd:          "rwd",   # Rear-Wheel Drive
    awd:          "awd",   # All-Wheel Drive
    four_wd:      "4wd"    # Four-Wheel Drive
  }, prefix: true

  enum :title_status, {
    clean:        "clean",
    rebuilt:      "rebuilt",
    salvage:      "salvage",
    flood:        "flood",
    lemon:        "lemon"
  }, prefix: true

  enum :condition, {
    new_vehicle:        "new",
    used:               "used",
    certified_pre_owned: "certified_pre_owned"
  }, prefix: true

  enum :currency, {
    usd: 0,
    cad: 1
  }


  validates :vin,       presence: true, uniqueness: { case_sensitive: false },
                        format: { with: /\A\d{17}\z/,
                                  message: "must have exactly 17 digits" }

  validates :year,      presence: true,
                        numericality: {
                          only_integer: true,
                          greater_than_or_equal_to: 1886,
                          less_than_or_equal_to: ->(_v) { Date.current.year + 2 }
                        }

  validates :mileage,   presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :condition, presence: true
  validates :title_status, presence: true

  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :currency,    presence: true

  validates :doors,     numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :seats,     numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validates :mpg_city,    numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :mpg_highway, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validates :owners_count,   numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :accident_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :title_status_consistent_with_flags

  scope :active,              -> { joins(:veihcle_listing).where(veihcle_listings: { status: "published" }) }
  scope :published_on_marketplace, -> { joins(:veihcle_listing).where(veihcle_listings: { status: "published" }) }
  scope :by_year,             ->(year) { where(year: year) }
  scope :year_range,          ->(from, to) { where(year: from..to) }
  scope :by_condition,        ->(cond) { where(condition: cond) }
  scope :price_up_to,         ->(cents) { where("price_cents <= ?", cents) }
  scope :price_range,         ->(from, to) { where(price_cents: from..to) }
  scope :mileage_up_to,       ->(miles) { where("mileage <= ?", miles) }
  scope :clean_title,         -> { where(title_status: :clean) }
  scope :no_accidents,        -> { where(accident_count: 0) }
  scope :one_owner,           -> { where(owners_count: 1) }
  scope :by_fuel_type,        ->(type) { where(fuel_type: type) }
  scope :by_drivetrain,       ->(type) { where(drivetrain: type) }
  scope :by_transmission,     ->(type) { where(transmission: type) }
  scope :by_exterior_color,   ->(color) { where("lower(exterior_color) = ?", color.downcase) }
  scope :recent,              -> { order(created_at: :desc) }

  delegate :name,  to: :car_model, prefix: :car_model, allow_nil: true
  delegate :brand, to: :car_model, allow_nil: true

  def price
    return nil if price_cents.nil?

    price_cents / 100.0
  end

  def price=(value)
    self.price_cents = (value.to_f * 100).round
  end

  def full_name
    "#{year} #{brand&.name} #{car_model&.name}".squish
  end

  def clean_history?
    !salvage_title? && !flood_damage? && !frame_damage? && !lemon_history? && accident_count == 0
  end

  def electric?
    fuel_type_electric?
  end

  def mpg_combined
    return nil if mpg_city.nil? || mpg_highway.nil?

    ((mpg_city * 0.55) + (mpg_highway * 0.45)).round(1)
  end

  def history_flags
    {
      salvage_title: salvage_title?,
      flood_damage:  flood_damage?,
      frame_damage:  frame_damage?,
      lemon_history: lemon_history?,
      accidents:     accident_count
    }
  end

  def age
    Date.current.year - year
  end

  private

  def title_status_consistent_with_flags
    if salvage_title? && !%w[salvage rebuilt].include?(title_status)
      errors.add(:title_status, "must be 'salvage' or 'rebuilt' when salvage_title is true")
    end

    if flood_damage? && title_status != "flood"
      errors.add(:title_status, "must be 'flood' when flood_damage is true")
    end

    if lemon_history? && title_status != "lemon"
      errors.add(:title_status, "must be 'lemon' when lemon_history is true")
    end
  end
end

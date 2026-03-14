class PublicListingSearch
  attr_reader :relation

  DEFAULT_LISTING_ORDER_COLUMNS = [ "updated_at", "published_at" ].freeze

  def initialize(filters = {})
    @filters = filters.to_h.symbolize_keys
    @relation = VehicleListing
      .published
      .joins(vehicle: [ :user, { car_model: :brand } ])
      .includes(vehicle: [ :user, { car_model: :brand }, photos_attachments: :blob ])
  end

  def results
    apply_filters.order(Arel.sql(default_order_clause))
  end

  private

  def apply_filters
    filter_body_type
    filter_brand
    filter_model
    filter_years
    filter_prices
    filter_mileage
    filter_color
    filter_transmission
    filter_location
    filter_plate_ending
    relation
  end

  def filter_body_type
    return if @filters[:body_type].blank?

    @relation = relation.where(car_models: { body_type: @filters[:body_type] })
  end

  def filter_brand
    if @filters[:brand_id].present?
      @relation = relation.where(car_models: { brand_id: @filters[:brand_id] })
    elsif @filters[:brand].present?
      @relation = relation.where("brands.name ILIKE ?", @filters[:brand].to_s)
    end
  end

  def filter_model
    return if @filters[:model].blank? && @filters[:series].blank?

    terms = [ @filters[:model], @filters[:series] ].compact_blank
    terms.each do |term|
      @relation = relation.where("car_models.name ILIKE ?", "%#{term}%")
    end
  end

  def filter_years
    @relation = relation.where("vehicles.year >= ?", @filters[:min_year]) if @filters[:min_year].present?
    @relation = relation.where("vehicles.year <= ?", @filters[:max_year]) if @filters[:max_year].present?
  end

  def filter_prices
    @relation = relation.where("vehicles.price_cents >= ?", @filters[:min_price].to_i * 100) if @filters[:min_price].present?
    @relation = relation.where("vehicles.price_cents <= ?", @filters[:max_price].to_i * 100) if @filters[:max_price].present?
  end

  def filter_mileage
    return if @filters[:max_mileage].blank?

    @relation = relation.where("vehicles.mileage <= ?", @filters[:max_mileage])
  end

  def filter_color
    return if @filters[:color].blank?

    @relation = relation.where("vehicles.exterior_color ILIKE ?", @filters[:color].to_s)
  end

  def filter_transmission
    return if @filters[:transmission].blank?

    @relation = relation.where("vehicles.transmission ILIKE ?", @filters[:transmission].to_s)
  end

  def filter_location
    city = @filters[:city].presence
    state = @filters[:state].presence
    location = @filters[:location].presence

    if city.present? || state.present?
      clauses = []
      values = {}

      if city.present?
        clauses << "users.address_city ILIKE :city"
        values[:city] = "%#{city}%"
      end

      if state.present?
        clauses << "users.address_state ILIKE :state"
        values[:state] = "%#{state}%"
      end

      @relation = relation.where(clauses.join(" OR "), values)
    elsif location.present?
      @relation = relation.where("users.address_city ILIKE :loc OR users.address_state ILIKE :loc", loc: "%#{location}%")
    end
  end

  def filter_plate_ending
    return if @filters[:plate_ending].blank?

    @relation = relation.where("vehicles.vin LIKE ?", "%#{@filters[:plate_ending]}")
  end

  def default_order_clause
    listing_table = VehicleListing.table_name
    listing_columns = VehicleListing.column_names

    if listing_columns.include?("updated_at")
      "#{listing_table}.updated_at DESC"
    elsif listing_columns.include?("published_at")
      "#{listing_table}.published_at DESC NULLS LAST, vehicles.updated_at DESC"
    else
      "vehicles.updated_at DESC"
    end
  end
end

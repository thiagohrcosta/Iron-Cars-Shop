class LeadInterestParser
  US_STATES = {
    "alabama" => "AL",
    "alaska" => "AK",
    "arizona" => "AZ",
    "arkansas" => "AR",
    "california" => "CA",
    "colorado" => "CO",
    "connecticut" => "CT",
    "delaware" => "DE",
    "florida" => "FL",
    "georgia" => "GA",
    "hawaii" => "HI",
    "idaho" => "ID",
    "illinois" => "IL",
    "indiana" => "IN",
    "iowa" => "IA",
    "kansas" => "KS",
    "kentucky" => "KY",
    "louisiana" => "LA",
    "maine" => "ME",
    "maryland" => "MD",
    "massachusetts" => "MA",
    "michigan" => "MI",
    "minnesota" => "MN",
    "mississippi" => "MS",
    "missouri" => "MO",
    "montana" => "MT",
    "nebraska" => "NE",
    "nevada" => "NV",
    "new hampshire" => "NH",
    "new jersey" => "NJ",
    "new mexico" => "NM",
    "new york" => "NY",
    "north carolina" => "NC",
    "north dakota" => "ND",
    "ohio" => "OH",
    "oklahoma" => "OK",
    "oregon" => "OR",
    "pennsylvania" => "PA",
    "rhode island" => "RI",
    "south carolina" => "SC",
    "south dakota" => "SD",
    "tennessee" => "TN",
    "texas" => "TX",
    "utah" => "UT",
    "vermont" => "VT",
    "virginia" => "VA",
    "washington" => "WA",
    "west virginia" => "WV",
    "wisconsin" => "WI",
    "wyoming" => "WY"
  }.freeze

  def initialize(interested_in)
    @interested_in = Array(interested_in)
  end

  def to_filters
    filters = {}

    @interested_in.each do |entry|
      key, value = normalize_entry(entry)
      next if key.blank? || value.blank?

      case key
      when "brand"
        filters[:brand] = value
      when "model"
        filters[:model] = value
      when "series"
        filters[:series] = value
      when "budget"
        budget = numeric_value(value)
        next unless budget.positive?

        filters[:budget] = budget
        filters[:min_price] ||= [(budget * 0.9).floor, 0].max
        filters[:max_price] ||= (budget * 1.1).ceil
      when "city"
        filters[:city] = value
      when "state"
        filters[:state] = normalize_state(value)
      when "body_type"
        filters[:body_type] = value.parameterize.underscore
      when "color"
        filters[:color] = value
      when "transmission"
        filters[:transmission] = value.parameterize.underscore
      when "year"
        year = numeric_value(value)
        filters[:min_year] = year if year.positive?
        filters[:max_year] = year if year.positive?
      when "min_year", "max_year", "min_price", "max_price", "max_mileage"
        amount = numeric_value(value)
        filters[key.to_sym] = amount if amount.positive?
      when "location"
        filters[:location] = value
      end
    end

    filters
  end

  private

  def normalize_entry(entry)
    raw = entry.to_s.strip
    return if raw.blank?

    if raw.include?(":")
      key, value = raw.split(":", 2)
      [key.to_s.strip.downcase, value.to_s.strip]
    else
      infer_freeform_entry(raw)
    end
  end

  def infer_freeform_entry(raw)
    return [ "year", raw ] if raw.match?(/\A\d{4}\z/)
    return [ "budget", raw ] if raw.match?(/\A\$?\d[\d,.]*\z/)
    return [ "state", normalize_state(raw) ] if state_like?(raw)
    return [ "brand", matched_brand_name(raw) ] if matched_brand_name(raw).present?
    return [ "city", raw ] if matched_city?(raw)

    [ "keyword", raw ]
  end

  def numeric_value(raw)
    raw.to_s.gsub(/[^\d]/, "").to_i
  end

  def state_like?(raw)
    normalized = raw.to_s.strip.downcase
    US_STATES.key?(normalized) || US_STATES.value?(normalized.upcase)
  end

  def normalize_state(raw)
    normalized = raw.to_s.strip
    return normalized if normalized.blank?

    US_STATES[normalized.downcase] || normalized.upcase
  end

  def matched_brand_name(raw)
    normalized = raw.to_s.strip
    return if normalized.blank?

    Brand.where("brands.name ILIKE :exact OR brands.name ILIKE :partial", exact: normalized, partial: "%#{normalized}%")
      .order(Arel.sql("LENGTH(brands.name) ASC"))
      .limit(1)
      .pick(:name)
  end

  def matched_city?(raw)
    normalized = raw.to_s.strip
    return false if normalized.blank?

    User.where("address_city ILIKE ?", normalized).exists?
  end
end

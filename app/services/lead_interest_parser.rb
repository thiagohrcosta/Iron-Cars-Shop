class LeadInterestParser
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
        filters[:state] = value
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

    [ "keyword", raw ]
  end

  def numeric_value(raw)
    raw.to_s.gsub(/[^\d]/, "").to_i
  end
end

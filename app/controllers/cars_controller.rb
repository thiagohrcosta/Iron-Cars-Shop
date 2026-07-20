require "digest"

class CarsController < ApplicationController
  def index
    # We build the base query. We DO NOT use .includes() here because it causes massive memory
    # overhead for .count and forces implicit cross-joins when we .pluck(:id) later.
    @vehicles_query = Vehicle.published_on_marketplace

    # Explicitly join car_models ONLY if we need to filter by its columns
    if params[:body_type].present? || params[:brand_id].present?
      @vehicles_query = @vehicles_query.joins(:car_model)
      @vehicles_query = @vehicles_query.where(car_models: { body_type: params[:body_type] }) if params[:body_type].present?
      @vehicles_query = @vehicles_query.where(car_models: { brand_id: params[:brand_id] }) if params[:brand_id].present?
    end
    @vehicles_query = @vehicles_query.where("vehicles.year >= ?", params[:min_year]) if params[:min_year].present?
    @vehicles_query = @vehicles_query.where("vehicles.year <= ?", params[:max_year]) if params[:max_year].present?
    @vehicles_query = @vehicles_query.where("vehicles.price_cents >= ?", params[:min_price].to_i * 100) if params[:min_price].present?
    @vehicles_query = @vehicles_query.where("vehicles.price_cents <= ?", params[:max_price].to_i * 100) if params[:max_price].present?
    @vehicles_query = @vehicles_query.where("vehicles.mileage <= ?", params[:max_mileage]) if params[:max_mileage].present?
    @vehicles_query = @vehicles_query.where("vehicles.exterior_color ILIKE ?", params[:color]) if params[:color].present?
    @vehicles_query = @vehicles_query.where("vehicles.transmission ILIKE ?", params[:transmission]) if params[:transmission].present?
    @vehicles_query = @vehicles_query.where("vehicles.vin LIKE ?", "%#{params[:plate_ending]}") if params[:plate_ending].present?

    if params[:location].present?
      @vehicles_query = @vehicles_query.joins(:user).where("users.address_city ILIKE :loc OR users.address_state ILIKE :loc", loc: "%#{params[:location]}%")
    end

    # Caching strategy: Counting 250k+ rows doing JOINs and GROUP BY on every reload is a huge bottleneck.
    # We cache these analytical results securely calculating an SHA of current exact query filters.
    cache_fingerprint = Digest::SHA1.hexdigest(request.query_parameters.except(:page, :cursor).to_json)

    @total_vehicles_count = Rails.cache.fetch("vc_count_#{cache_fingerprint}", expires_in: 5.minutes) do
      @vehicles_query.count
    end

    @body_type_counts = Rails.cache.fetch("body_type_counts_marketplace", expires_in: 30.minutes) do
      Vehicle.published_on_marketplace.joins(:car_model).group("car_models.body_type").count
    end

    # Fast Numbered Pagination (Deferred Join technique):
    # Standard LIMIT/OFFSET gets slow on large tables because it fetches and discards huge rows.
    # We solve this by first fetchingONLY the IDs via the primary key index.
    @current_page = [ params[:page].to_i, 1 ].max
    @vehicles_per_page = 9
    @total_pages = (@total_vehicles_count / @vehicles_per_page.to_f).ceil

    offset_value = (@current_page - 1) * @vehicles_per_page
    vehicle_ids = @vehicles_query.order("vehicles.id DESC").offset(offset_value).limit(@vehicles_per_page).pluck("vehicles.id")

    @vehicles = if vehicle_ids.any?
      Vehicle.published_on_marketplace
        .includes(:vehicle_features, car_model: :brand, photos_attachments: :blob)
        .where(id: vehicle_ids)
        .sort_by { |v| vehicle_ids.index(v.id) } # Restore sort order
    else
      []
    end
  end

  def show
    @vehicle = Vehicle.published_on_marketplace
      .includes(:vehicle_features, photos_attachments: :blob, car_model: :brand)
      .find_by(id: params[:id])

    @vehicle ||= Vehicle.published_on_marketplace
      .includes(:vehicle_features, photos_attachments: :blob, car_model: :brand)
      .order(created_at: :desc)
      .first

    @similar_vehicles = if @vehicle.present?
      Vehicle.published_on_marketplace
        .includes(car_model: :brand, photos_attachments: :blob)
        .where.not(id: @vehicle.id)
        .order(created_at: :desc)
        .limit(5)
    else
      []
    end
  end
end

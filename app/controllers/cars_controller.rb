class CarsController < ApplicationController
  def index
    @vehicles = Vehicle.published_on_marketplace
      .includes(car_model: :brand, photos_attachments: :blob)
      .order(created_at: :desc)

    if params[:body_type].present?
      @vehicles = @vehicles.where(car_models: { body_type: params[:body_type] })
    end

    @total_vehicles_count = @vehicles.count
    @body_type_counts = Vehicle.published_on_marketplace.joins(:car_model).group("car_models.body_type").count

    @vehicles = @vehicles.limit(9)
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

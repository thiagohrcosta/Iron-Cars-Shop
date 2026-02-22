class User::VehiclesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!
  before_action :set_form_options, only: [ :new, :create ]

  def index
    @vehicles = current_user.vehicles.includes(car_model: :brand).order(created_at: :desc)
  end

  def new
    @vehicle = Vehicle.new
    @vehicle.year = 2026
    @vehicle.currency = 0
    @vehicle.condition = "used"
    @vehicle.title_status = "clean"
  end

  def create
    @vehicle = current_user.vehicles.build(vehicle_params)

    if @vehicle.save
      redirect_to user_dashboard_path, notice: "Vehicle listing created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_form_options
    @brands = Brand.order(:name)
    @models_by_brand = CarModel.order(:name).group_by(&:brand_id).transform_values do |models|
      models.map { |model| [ model.name, model.id ] }
    end
    @year_options = (1950..2026).to_a.reverse
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :vin,
      :car_model_id,
      :year,
      :mileage,
      :condition,
      :exterior_color,
      :interior_color,
      :transmission,
      :fuel_type,
      :drivetrain,
      :doors,
      :seats,
      :engine_description,
      :title_status,
      :currency,
      :price,
      photos: []
    )
  end

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end
end

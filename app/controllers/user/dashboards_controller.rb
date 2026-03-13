class User::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  def show
    @my_listings = current_user.vehicles
      .left_outer_joins(:vehicle_listing)
      .includes(:vehicle_listing, car_model: :brand)
      .where("veihcle_listings.id IS NULL OR veihcle_listings.status != ? OR veihcle_listings.expires_at >= ?", "sold", Time.current)
      .order(created_at: :desc)
      .limit(5)
  end

  private

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end
end

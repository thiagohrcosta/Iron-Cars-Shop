class User::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  def show
  end

  private

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end
end

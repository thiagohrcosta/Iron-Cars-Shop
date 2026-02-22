class Admin::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def show
  end

  private

  def require_admin!
    redirect_to user_dashboard_path unless current_user.admin?
  end
end

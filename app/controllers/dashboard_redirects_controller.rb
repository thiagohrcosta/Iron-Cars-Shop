class DashboardRedirectsController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.admin?
      redirect_to admin_dashboard_path
    else
      redirect_to user_dashboard_path
    end
  end
end

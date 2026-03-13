class User::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  def show
    if current_user.can_access_analytics?
      load_analytics_data
      render :show
    else
      @plans = analytics_plans
      render :paywall
    end
  end

  private

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end

  def load_analytics_data
    listings = current_user.vehicles.includes(:vehicle_listing)
    published = listings.select { |vehicle| vehicle.vehicle_listing&.published? }

    @stats = {
      total_cars: listings.size,
      published_cars: published.size,
      sold_cars: listings.count { |vehicle| vehicle.vehicle_listing&.sold? },
      total_views: published.sum { |vehicle| vehicle.vehicle_listing&.views_count.to_i },
      avg_ticket: listings.any? ? (listings.sum { |vehicle| vehicle.price_cents.to_i } / listings.size.to_f / 100).round(2) : 0
    }

    @top_vehicles = listings
      .sort_by { |vehicle| -vehicle.vehicle_listing&.views_count.to_i }
      .first(5)

    @lead_sources = [
      { name: "Website", percent: 44 },
      { name: "Instagram", percent: 21 },
      { name: "Facebook Ads", percent: 18 },
      { name: "Referral", percent: 10 },
      { name: "Direct", percent: 7 }
    ]
  end

  def analytics_plans
    [
      {
        key: :iron_cars_pro,
        title: "Iron Cars Pro",
        price: "$19/month",
        description: "For stores with up to 5 cars listed.",
        features: [ "Analytics dashboard", "Lead source insights", "Monthly performance report" ]
      },
      {
        key: :iron_cars_premium,
        title: "Iron Cars Premium",
        price: "$49/month",
        description: "For stores with more than 5 cars listed.",
        features: [ "Everything in Pro", "Advanced conversion metrics", "Pipeline and funnel tracking" ]
      },
      {
        key: :iron_cars_premium_ai,
        title: "Iron Cars Premium AI",
        price: "$69/month",
        description: "Everything from Premium + AI insights.",
        features: [ "Everything in Premium", "AI deal recommendations", "AI trend highlights" ]
      }
    ]
  end
end

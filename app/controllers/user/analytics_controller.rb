class User::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_user!

  TIME_FILTERS = {
    "30d" => 30,
    "60d" => 60,
    "90d" => 90,
    "6m" => 180,
    "12m" => 365
  }.freeze

  LEAD_SOURCES = [ "Website", "Instagram", "Facebook Ads", "Referral", "Direct" ].freeze

  def show
    if current_user.can_access_analytics?
      load_analytics_data
      render :show
    else
      @plans = analytics_plans
      render :paywall
    end
  end

  def data
    return head :forbidden unless current_user.can_access_analytics?

    load_analytics_data
    render json: {
      selected_range: @selected_range,
      time_filters: @time_filters,
      stats: @stats,
      revenue_series: @revenue_series,
      daily_sales_series: @daily_sales_series,
      lead_sources: @lead_sources
    }
  end

  private

  def require_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end

  def load_analytics_data
    @selected_range = normalize_range(params[:range])
    report = SellerReport.new(seller: current_user, days: TIME_FILTERS.fetch(@selected_range))

    @revenue_series = report.revenue_series
    @daily_sales_series = report.daily_sales_series
    @stats = report.stats
    @top_vehicles = report.top_vehicles
    @lead_sources = LEAD_SOURCES.map { |name| { name: name, percent: 0 } }
    @time_filters = TIME_FILTERS.keys.map { |key| { key: key, label: filter_label(key), active: key == @selected_range } }
  end

  def normalize_range(raw_range)
    key = raw_range.to_s
    TIME_FILTERS.key?(key) ? key : "30d"
  end

  def filter_label(key)
    {
      "30d" => "30 days",
      "60d" => "60 days",
      "90d" => "90 days",
      "6m" => "6 months",
      "12m" => "12 months"
    }.fetch(key, key)
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

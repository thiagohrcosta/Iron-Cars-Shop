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
    days = TIME_FILTERS.fetch(@selected_range)

    listings = current_user.vehicles.includes(:vehicle_listing)
    published = listings.select { |vehicle| vehicle.vehicle_listing&.published? }
    sold_listings = listings.select { |vehicle| vehicle.vehicle_listing&.sold? }

    range_start = days.days.ago.to_date
    dates = (range_start..Date.current).to_a

    sold_by_day = sold_listings.each_with_object(Hash.new { |hash, key| hash[key] = { revenue_cents: 0, sales_count: 0 } }) do |vehicle, grouped|
      sold_on = vehicle.vehicle_listing&.updated_at&.to_date
      next if sold_on.blank? || sold_on < range_start

      grouped[sold_on][:revenue_cents] += vehicle.price_cents.to_i
      grouped[sold_on][:sales_count] += 1
    end

    @revenue_series = dates.map do |date|
      {
        date: date.iso8601,
        value: sold_by_day[date][:revenue_cents] / 100.0
      }
    end

    @daily_sales_series = dates.map do |date|
      {
        date: date.iso8601,
        value: sold_by_day[date][:sales_count]
      }
    end

    sold_this_month = sold_listings.count do |vehicle|
      vehicle.vehicle_listing&.updated_at&.between?(Date.current.beginning_of_month, Time.current)
    end

    revenue_today_cents = sold_by_day[Date.current][:revenue_cents]
    revenue_last_30_days_cents = sold_listings.sum do |vehicle|
      sold_on = vehicle.vehicle_listing&.updated_at&.to_date
      next 0 if sold_on.blank? || sold_on < 30.days.ago.to_date

      vehicle.price_cents.to_i
    end

    total_revenue_cents = sold_listings.sum { |vehicle| vehicle.price_cents.to_i }
    total_sold_count = sold_listings.size
    avg_deal_value = total_sold_count.positive? ? (total_revenue_cents / total_sold_count.to_f / 100).round(2) : 0

    total_leads = current_user.negotiations_as_seller.count
    conversion_rate = total_leads.positive? ? ((total_sold_count.to_f / total_leads) * 100).round(1) : 0.0

    @stats = {
      total_cars: listings.size,
      published_cars: published.size,
      sold_cars: sold_this_month,
      total_views: published.sum { |vehicle| vehicle.vehicle_listing&.views_count.to_i },
      avg_ticket: avg_deal_value,
      revenue_today: revenue_today_cents / 100.0,
      revenue_last_30_days: revenue_last_30_days_cents / 100.0,
      selected_range_revenue: @revenue_series.sum { |point| point[:value] },
      selected_range_sales: @daily_sales_series.sum { |point| point[:value] },
      conversion_rate: conversion_rate
    }

    @top_vehicles = listings
      .sort_by { |vehicle| -vehicle.vehicle_listing&.views_count.to_i }
      .first(5)

    @lead_sources = [
      { name: "Website", percent: 0 },
      { name: "Instagram", percent: 0 },
      { name: "Facebook Ads", percent: 0 },
      { name: "Referral", percent: 0 },
      { name: "Direct", percent: 0 }
    ]

    @time_filters = TIME_FILTERS.keys.map do |key|
      {
        key: key,
        label: filter_label(key),
        active: key == @selected_range
      }
    end
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

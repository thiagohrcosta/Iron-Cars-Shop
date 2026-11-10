# A seller's dashboard numbers, aggregated in the database.
# A sale is dated by when the deal closed (sold_at) and counted at what it closed
# for (sold_price_cents), never by the SOLD badge's expiry or the asking price.
class SellerReport
  TOP_VEHICLES_LIMIT = 5

  attr_reader :seller, :days

  def initialize(seller:, days:)
    @seller = seller
    @days = days
  end

  def revenue_series
    @revenue_series ||= dates.map { |date| { date: date.iso8601, value: revenue_by_day.fetch(date, 0) / 100.0 } }
  end

  def daily_sales_series
    @daily_sales_series ||= dates.map { |date| { date: date.iso8601, value: sales_by_day.fetch(date, 0) } }
  end

  def stats
    {
      total_cars: seller.vehicles.count,
      published_cars: published_listings.count,
      sold_cars: sales.where(sold_at: Time.current.beginning_of_month..).count,
      total_views: published_listings.sum(:views_count),
      avg_ticket: (average_deal_cents / 100).round(2),
      revenue_today: revenue_cents_since(Time.current.beginning_of_day) / 100.0,
      revenue_last_30_days: revenue_cents_since(30.days.ago.beginning_of_day) / 100.0,
      selected_range_revenue: revenue_series.sum { |point| point[:value] },
      selected_range_sales: daily_sales_series.sum { |point| point[:value] },
      conversion_rate: conversion_rate
    }
  end

  def top_vehicles
    seller.vehicles
      .left_joins(:vehicle_listing)
      .includes(:vehicle_listing, car_model: :brand)
      .order(VehicleListing.arel_table[:views_count].desc.nulls_last)
      .limit(TOP_VEHICLES_LIMIT)
  end

  private

  def dates
    @dates ||= (days.days.ago.to_date..Date.current).to_a
  end

  def listings
    VehicleListing.where(seller: seller)
  end

  def published_listings
    listings.published
  end

  def sales
    listings.sold
  end

  def revenue_cents_since(time)
    sales.where(sold_at: time..).sum(:sold_price_cents)
  end

  def average_deal_cents
    count = sales.count
    count.positive? ? sales.sum(:sold_price_cents) / count.to_f : 0
  end

  def conversion_rate
    negotiations = seller.negotiations_as_seller.count
    negotiations.positive? ? (sales.count * 100.0 / negotiations).round(1) : 0.0
  end

  def revenue_by_day
    @revenue_by_day ||= sales_in_period.sum(:sold_price_cents)
  end

  def sales_by_day
    @sales_by_day ||= sales_in_period.count
  end

  def sales_in_period
    sales.where(sold_at: dates.first.beginning_of_day..).group(local_sale_date)
  end

  # Group by the sale's calendar day in the app's time zone, not the database's (UTC).
  def local_sale_date
    Arel.sql(ActiveRecord::Base.sanitize_sql_array(
      [ "DATE(sold_at AT TIME ZONE 'UTC' AT TIME ZONE ?)", Time.zone.tzinfo.identifier ]
    ))
  end
end

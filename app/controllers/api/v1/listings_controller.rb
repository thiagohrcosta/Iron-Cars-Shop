class Api::V1::ListingsController < Api::V1::BaseController
  def index
    filters = filter_params.to_h.symbolize_keys
    filters.reverse_merge!(LeadInterestParser.new(params[:interested_in]).to_filters) if params[:interested_in].present?

    listings = PublicListingSearch.new(filters).results.limit(limit).to_a

    render json: {
      filters: filters,
      total: listings.size,
      listings: listings.map { |listing| serialize_listing(listing) }
    }
  end

  private

  def filter_params
    params.permit(
      :body_type, :brand_id, :brand, :model, :series, :min_year, :max_year,
      :min_price, :max_price, :max_mileage, :location, :city, :state,
      :color, :transmission, :plate_ending, :limit
    )
  end

  def limit
    requested = params[:limit].to_i
    return 20 if requested <= 0

    [ requested, 50 ].min
  end

  def serialize_listing(listing)
    vehicle = listing.vehicle

    {
      listing_id: listing.id,
      vehicle_id: vehicle.id,
      vehicle_name: vehicle.full_name,
      brand: vehicle.brand&.name,
      model: vehicle.car_model&.name,
      body_type: vehicle.car_model&.body_type,
      year: vehicle.year,
      price: vehicle.price,
      mileage: vehicle.mileage,
      transmission: vehicle.transmission,
      color: vehicle.exterior_color,
      seller_location: {
        city: listing.seller.address_city,
        state: listing.seller.address_state,
        country: listing.seller.address_country
      },
      public_url: car_url(vehicle)
    }
  end
end

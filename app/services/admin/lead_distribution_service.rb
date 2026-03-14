module Admin
  class LeadDistributionService
    MINIMUM_MATCH_SCORE = 20

    Result = Struct.new(:success?, :lead, :negotiation, :listing, :message, keyword_init: true)

    def initialize(lead:, actor:)
      @lead = lead
      @actor = actor
    end

    def call
      return already_distributed_result if @lead.distributed?

      listing = best_listing_match
      return no_match_result unless listing

      negotiation = create_negotiation!(listing)

      @lead.update!(
        matched_vehicle_listing: listing,
        matched_seller: listing.seller,
        distributed_at: Time.current,
        status: :contacted
      )

      Result.new(
        success?: true,
        lead: @lead,
        negotiation: negotiation,
        listing: listing,
        message: "#{@lead.name} was matched with #{listing.vehicle.full_name}."
      )
    end

    private

    def best_listing_match
      filters = LeadInterestParser.new(@lead.interested_in).to_filters
      candidates = progressive_candidates(filters)
      best_match = candidates.max_by { |listing| score_listing(listing, filters) }
      return if best_match.blank?

      score_listing(best_match, filters) >= MINIMUM_MATCH_SCORE ? best_match : nil
    end

    def progressive_candidates(filters)
      search_variants(filters).each do |variant|
        matches = PublicListingSearch.new(variant).results.limit(20).to_a
        return matches if matches.any?
      end

      PublicListingSearch.new({}).results.limit(20).to_a
    end

    def search_variants(filters)
      [
        filters,
        filters.except(:city, :state, :location),
        filters.except(:color, :transmission, :max_mileage),
        filters.except(:city, :state, :location, :color, :transmission, :max_mileage),
        filters.except(:series),
        filters.except(:series, :model),
        filters.slice(:brand, :budget, :min_price, :max_price, :city, :state),
        filters.slice(:brand, :budget, :min_price, :max_price),
        filters.slice(:budget, :min_price, :max_price, :city, :state),
        filters.slice(:budget, :min_price, :max_price),
        {}
      ].map(&:compact_blank).uniq
    end

    def score_listing(listing, filters)
      vehicle = listing.vehicle
      score = 0

      score += 40 if filters[:brand].present? && vehicle.brand&.name.to_s.casecmp?(filters[:brand].to_s)
      score += 35 if filters[:model].present? && vehicle.car_model.name.to_s.downcase.include?(filters[:model].to_s.downcase)
      score += 20 if filters[:series].present? && vehicle.car_model.name.to_s.downcase.include?(filters[:series].to_s.downcase)
      score += 15 if filters[:city].present? && listing.seller.address_city.to_s.casecmp?(filters[:city].to_s)
      score += 10 if filters[:state].present? && listing.seller.address_state.to_s.casecmp?(filters[:state].to_s)
      score += 10 if filters[:transmission].present? && vehicle.transmission.to_s.casecmp?(filters[:transmission].to_s)
      score += 8 if filters[:color].present? && vehicle.exterior_color.to_s.casecmp?(filters[:color].to_s)
      score += [ 8 - (vehicle.mileage.to_i / 20_000), 0 ].max

      if filters[:budget].present?
        price_delta = ((vehicle.price_cents / 100.0) - filters[:budget].to_f).abs
        score += [ 25 - (price_delta / 2_500).round, 0 ].max
      end
      score += 12 if filters[:min_price].present? && filters[:max_price].present? &&
        vehicle.price_cents.to_i.between?(filters[:min_price].to_i * 100, filters[:max_price].to_i * 100)

      score += [ vehicle.year.to_i - 2015, 0 ].max
      score
    end

    def create_negotiation!(listing)
      Negotiation.transaction do
        negotiation = Negotiation.create!(
          vehicle_listing: listing,
          vehicle: listing.vehicle,
          buyer: nil,
          lead: @lead,
          seller: listing.seller,
          price_cents: listing.vehicle.price_cents,
          accepted_by_buyer: false,
          accepted_by_seller: false,
          status: "pending"
        )
        negotiation.ensure_public_access_token!

        negotiation.negotiation_messages.create!(
          user: @actor,
          content: <<~TEXT.squish
            LOCALIZEI ESTE LEAD PARA VOCÊ. Lead: #{@lead.name} (#{@lead.email}#{@lead.phone.present? ? ", #{@lead.phone}" : ""}).
            Interesse: #{@lead.interested_in.join(", ")}.
            Se houver interesse, inicie a conversa com o comprador. Nós cuidaremos de avisar ele.
          TEXT
        )

        negotiation
      end
    end

    def already_distributed_result
      Result.new(
        success?: false,
        lead: @lead,
        negotiation: @lead.negotiations.order(created_at: :desc).first,
        listing: @lead.matched_vehicle_listing,
        message: "#{@lead.name} has already been distributed."
      )
    end

    def no_match_result
      Result.new(
        success?: false,
        lead: @lead,
        negotiation: nil,
        listing: nil,
        message: "No listing reached the minimum similarity threshold for #{@lead.name}."
      )
    end
  end
end

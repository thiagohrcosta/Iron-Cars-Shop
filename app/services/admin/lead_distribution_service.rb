module Admin
  class LeadDistributionService
    AUTO_MATCH_SCORE = 72
    MINIMUM_SUGGESTION_SCORE = 20

    Result = Struct.new(
      :success?,
      :suggested?,
      :lead,
      :negotiation,
      :listing,
      :message,
      :score,
      :strategy,
      :matched_preferences,
      :tradeoffs,
      keyword_init: true
    )

    def initialize(lead:, actor:)
      @lead = lead
      @actor = actor
    end

    def call(strategy: :primary)
      return already_distributed_result if @lead.distributed?

      recommendation = best_listing_match(strategy: strategy)
      return no_match_result(strategy) unless recommendation

      if auto_distribute?(recommendation, strategy)
        distribute_listing!(recommendation[:listing], strategy: strategy, score: recommendation[:score])
      else
        suggestion_result(recommendation, strategy)
      end
    end

    def confirm!(listing:)
      return already_distributed_result if @lead.distributed?

      filters = LeadInterestParser.new(@lead.interested_in).to_filters
      distribute_listing!(listing, strategy: :manual_confirmation, score: score_listing(listing, filters))
    end

    private

    def best_listing_match(strategy:)
      filters = LeadInterestParser.new(@lead.interested_in).to_filters
      candidates = progressive_candidates(filters, strategy: strategy)
      best_match = candidates.max_by { |listing| score_listing(listing, filters) }
      return if best_match.blank?

      score = score_listing(best_match, filters)
      return if score < MINIMUM_SUGGESTION_SCORE

      {
        listing: best_match,
        score: score,
        filters: filters
      }
    end

    def progressive_candidates(filters, strategy:)
      search_variants(filters, strategy: strategy).each do |variant|
        matches = PublicListingSearch.new(variant).results.limit(20).to_a
        return matches if matches.any?
      end

      PublicListingSearch.new({}).results.limit(20).to_a
    end

    def search_variants(filters, strategy:)
      base_variants = [
        filters,
        filters.except(:city, :state, :location),
        filters.except(:color, :transmission, :max_mileage),
        filters.except(:city, :state, :location, :color, :transmission, :max_mileage),
        filters.except(:series),
        filters.except(:series, :model),
        filters.slice(:brand, :budget, :min_price, :max_price, :city, :state),
        filters.slice(:brand, :budget, :min_price, :max_price),
        filters.slice(:budget, :min_price, :max_price, :city, :state),
        filters.slice(:budget, :min_price, :max_price)
      ]

      expanded_variants = [
        widen_price_range(filters),
        filters.except(:min_price, :max_price, :budget),
        filters.slice(:brand, :model, :series, :city, :state),
        filters.slice(:brand, :model, :series),
        filters.slice(:brand, :model),
        filters.slice(:brand),
        {}
      ]

      variants = strategy.to_sym == :expanded ? base_variants + expanded_variants : base_variants
      variants.map(&:compact_blank).uniq
    end

    def widen_price_range(filters)
      return filters if filters[:max_price].blank? && filters[:budget].blank?

      widened = filters.dup
      budget_reference = filters[:budget].presence || filters[:max_price].presence
      widened[:min_price] = [ filters[:min_price].to_i * 0.8, 0 ].max if filters[:min_price].present?
      widened[:max_price] = [ filters[:max_price].to_i, budget_reference.to_i * 2 ].compact.max
      widened
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
        asking_price = vehicle.price_cents / 100.0
        target_budget = filters[:budget].to_f
        price_delta = (asking_price - target_budget).abs
        score += [ 25 - (price_delta / 10_000).round, 0 ].max
        score += 6 if asking_price > target_budget && asking_price <= (target_budget * 2)
      end
      score += 12 if filters[:min_price].present? && filters[:max_price].present? &&
        vehicle.price_cents.to_i.between?(filters[:min_price].to_i * 100, filters[:max_price].to_i * 100)

      score += [ vehicle.year.to_i - 2015, 0 ].max
      score
    end

    def auto_distribute?(recommendation, strategy)
      strategy.to_sym == :primary && recommendation[:score] >= AUTO_MATCH_SCORE
    end

    def suggestion_result(recommendation, strategy)
      filters = recommendation[:filters]
      listing = recommendation[:listing]
      Result.new(
        success?: false,
        suggested?: true,
        lead: @lead,
        listing: listing,
        score: recommendation[:score],
        strategy: strategy.to_s,
        matched_preferences: matched_preferences(listing, filters),
        tradeoffs: tradeoffs(listing, filters),
        message: suggestion_message(listing, recommendation[:score], strategy)
      )
    end

    def distribute_listing!(listing, strategy:, score:)
      negotiation = create_negotiation!(listing)

      @lead.update!(
        matched_vehicle_listing: listing,
        matched_seller: listing.seller,
        distributed_at: Time.current,
        status: :contacted
      )

      Result.new(
        success?: true,
        suggested?: false,
        lead: @lead,
        negotiation: negotiation,
        listing: listing,
        score: score,
        strategy: strategy.to_s,
        matched_preferences: [],
        tradeoffs: [],
        message: "#{@lead.name} was matched with #{listing.vehicle.full_name}."
      )
    end

    def suggestion_message(listing, score, strategy)
      if strategy.to_sym == :expanded
        "I relaxed the search and found #{listing.vehicle.full_name} as the closest option for #{@lead.name} (score #{score}). Please review it before distributing."
      else
        "I found a close match for #{@lead.name}: #{listing.vehicle.full_name} (score #{score}). Please confirm it or request a broader search."
      end
    end

    def matched_preferences(listing, filters)
      vehicle = listing.vehicle
      matches = []
      matches << "Brand matched: #{vehicle.brand&.name}" if filters[:brand].present? && vehicle.brand&.name.to_s.casecmp?(filters[:brand].to_s)
      matches << "Model matched: #{vehicle.car_model.name}" if filters[:model].present? && vehicle.car_model.name.to_s.downcase.include?(filters[:model].to_s.downcase)
      matches << "Series matched: #{filters[:series]}" if filters[:series].present? && vehicle.car_model.name.to_s.downcase.include?(filters[:series].to_s.downcase)
      matches << "Seller is in #{listing.seller.address_city}" if filters[:city].present? && listing.seller.address_city.to_s.casecmp?(filters[:city].to_s)
      matches << "Seller is in #{listing.seller.address_state}" if filters[:state].present? && listing.seller.address_state.to_s.casecmp?(filters[:state].to_s)
      matches << "Transmission matched: #{vehicle.transmission}" if filters[:transmission].present? && vehicle.transmission.to_s.casecmp?(filters[:transmission].to_s)
      matches << "Color matched: #{vehicle.exterior_color}" if filters[:color].present? && vehicle.exterior_color.to_s.casecmp?(filters[:color].to_s)
      matches << "Asking price: #{ApplicationController.helpers.number_to_currency(vehicle.price_cents / 100.0)}"
      matches
    end

    def tradeoffs(listing, filters)
      vehicle = listing.vehicle
      notes = []

      if filters[:budget].present? && (vehicle.price_cents / 100.0) > filters[:budget].to_f
        notes << "Price is above the requested budget: #{ApplicationController.helpers.number_to_currency(vehicle.price_cents / 100.0)} vs #{ApplicationController.helpers.number_to_currency(filters[:budget])}."
      end

      if filters[:city].present? && !listing.seller.address_city.to_s.casecmp?(filters[:city].to_s)
        notes << "Seller city differs from the requested region: #{listing.seller.address_city.presence || 'not informed'}."
      end

      if filters[:state].present? && !listing.seller.address_state.to_s.casecmp?(filters[:state].to_s)
        notes << "Seller state differs from the requested state: #{filters[:state]}."
      end

      if filters[:model].present? && !vehicle.car_model.name.to_s.downcase.include?(filters[:model].to_s.downcase)
        notes << "Model is not an exact match."
      end

      notes
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
        suggested?: false,
        lead: @lead,
        negotiation: @lead.negotiations.order(created_at: :desc).first,
        listing: @lead.matched_vehicle_listing,
        message: "#{@lead.name} has already been distributed."
      )
    end

    def no_match_result(strategy)
      Result.new(
        success?: false,
        suggested?: false,
        lead: @lead,
        negotiation: nil,
        listing: nil,
        message: if strategy.to_sym == :expanded
          "Even after widening the search, no reasonable match was found for #{@lead.name}."
        else
          "No strong automatic match was found for #{@lead.name}. Try the broader search suggestion flow."
        end
      )
    end
  end
end

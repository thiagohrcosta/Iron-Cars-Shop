class User::Negotiations::OffersController < ApplicationController
  include NegotiationScoped

  def create
    @negotiation.submit_offer!(by: current_user, price_cents: offer_price_cents)
    @negotiation.broadcast_offer_state
    redirect_to user_negotiation_path(@negotiation), notice: "Offer sent successfully."
  end

  private

  # The form sends dollars ("$32,000" or "32000.50"); commas are thousands separators.
  def offer_price_cents
    (params[:offer_price].to_s.gsub(/[^\d.]/, "").to_d * 100).round
  end
end

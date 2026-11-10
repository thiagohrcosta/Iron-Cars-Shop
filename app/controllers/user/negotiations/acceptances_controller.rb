class User::Negotiations::AcceptancesController < ApplicationController
  include NegotiationScoped

  def create
    @negotiation.accept!(by: current_user)
    @negotiation.broadcast_offer_state
    redirect_to user_negotiation_path(@negotiation), notice: "Offer accepted successfully."
  end
end

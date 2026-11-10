class User::Negotiations::RejectionsController < ApplicationController
  include NegotiationScoped

  def create
    @negotiation.reject!(by: current_user)
    @negotiation.broadcast_offer_state
    redirect_to user_negotiation_path(@negotiation), notice: "Offer rejected."
  end
end

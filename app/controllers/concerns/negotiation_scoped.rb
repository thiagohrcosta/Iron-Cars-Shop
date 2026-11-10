# For controllers nested under a negotiation: loads it from the current user's
# negotiations (404 otherwise) and turns a refused offer transition into a flash.
module NegotiationScoped
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_negotiation

    rescue_from Negotiation::InvalidTransition do |error|
      redirect_to user_negotiation_path(@negotiation), alert: error.message
    end
  end

  private

  def set_negotiation
    @negotiation = Negotiation.for_user(current_user).find(params[:negotiation_id])
  end
end

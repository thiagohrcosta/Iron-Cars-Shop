# Keeps both participants' offer panel and status badge live over Turbo Streams.
module Negotiation::Broadcasting
  extend ActiveSupport::Concern

  def broadcast_offer_state
    [ buyer_id, seller_id ].compact.uniq.each do |participant_id|
      Turbo::StreamsChannel.broadcast_replace_to(
        self, :meta, participant_id,
        target: "negotiation_#{id}_offer_panel",
        partial: "user/negotiations/offer_panel",
        locals: { negotiation: self, current_user_id: participant_id }
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        self, :meta, participant_id,
        target: "negotiation_#{id}_status_badge",
        partial: "user/negotiations/status_badge",
        locals: { negotiation: self }
      )
    end
  end
end

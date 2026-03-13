class NegotiationMessage < ApplicationRecord
  belongs_to :negotiation, touch: true
  belongs_to :user

  validates :content, presence: true, length: { maximum: 2000 }

  after_create_commit :broadcast_to_participants

  private

  def broadcast_to_participants
    [ negotiation.buyer_id, negotiation.seller_id ].uniq.each do |participant_id|
      Turbo::StreamsChannel.broadcast_append_to(
        negotiation,
        :messages,
        participant_id,
        target: "negotiation_#{negotiation.id}_messages",
        partial: "user/negotiation_messages/message",
        locals: { message: self, current_user_id: participant_id }
      )
    end
  end
end

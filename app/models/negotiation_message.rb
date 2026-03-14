class NegotiationMessage < ApplicationRecord
  belongs_to :negotiation, touch: true
  belongs_to :user, optional: true

  validates :content, presence: true, length: { maximum: 2000 }
  validate :author_present

  def author_name
    return "You" if user.present?
    return negotiation.lead.name if negotiation.lead&.name.present?

    negotiation.lead&.email || "Lead"
  end

  def guest_message?
    user_id.blank?
  end

  after_create_commit :broadcast_to_participants
  after_create_commit :notify_lead_if_needed

  private

  def broadcast_to_participants
    [ negotiation.buyer_id, negotiation.seller_id ].compact.uniq.each do |participant_id|
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

  def notify_lead_if_needed
    return unless negotiation.lead.present?
    return unless negotiation.seller_id == user_id
    return if negotiation.lead.email.blank?

    LeadNegotiationMailer.seller_message_notification(self).deliver_now
  end

  def author_present
    return if user.present?
    return if negotiation&.lead.present?

    errors.add(:base, "Message author is required")
  end
end

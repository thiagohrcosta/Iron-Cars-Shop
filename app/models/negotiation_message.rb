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
  after_create_commit :notify_account_participants_if_needed

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

  def notify_account_participants_if_needed
    account_recipients.each do |recipient|
      next if notification_throttled_for?(recipient)

      mark_notified_for!(recipient)
      NegotiationMailer.new_message_notification(self, recipient).deliver_now
    end
  end

  def account_recipients
    [ negotiation.buyer, negotiation.seller ].compact.select do |participant|
      participant.id != user_id && participant.email.present?
    end
  end

  def notification_throttled_for?(recipient)
    last_notified_at = negotiation.public_send(last_notified_column_for(recipient))
    last_notified_at.present? && last_notified_at > 30.minutes.ago
  end

  def mark_notified_for!(recipient)
    negotiation.update_column(last_notified_column_for(recipient), Time.current)
  end

  def last_notified_column_for(recipient)
    negotiation.buyer?(recipient) ? :buyer_last_notified_at : :seller_last_notified_at
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

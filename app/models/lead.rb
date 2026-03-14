class Lead < ApplicationRecord
  enum :status, { new: 0, contacted: 1, qualified: 2, lost: 3 }, prefix: true
  enum :source, { facebook_ads: 0, referral: 1, iron_cars_website: 2, agent_lead: 3 }

  normalizes :email, with: ->(value) { value.to_s.strip.downcase.presence }
  normalizes :phone, with: ->(value) { value.to_s.strip.presence }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :interested_in, presence: true

  def interested_in=(value)
    super(Array(value).filter_map { |item| item.to_s.strip.presence }.uniq)
  end
end

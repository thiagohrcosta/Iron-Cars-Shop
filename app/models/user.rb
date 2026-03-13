class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :photo
  has_many :vehicles, dependent: :destroy
  has_many :negotiations_as_buyer, class_name: "Negotiation", foreign_key: "buyer_id", dependent: :destroy
  has_many :negotiations_as_seller, class_name: "Negotiation", foreign_key: "seller_id", dependent: :destroy
  has_many :negotiation_messages, dependent: :destroy
  has_one :subscription, dependent: :destroy

  validates :full_name,
            :document_id,
            :phone_number,
            :address_street,
            :address_number,
            :address_city,
            :address_state,
            :address_zip_code,
            :address_country,
            presence: true

  enum :role, { user: 0, admin: 1 }

  def active_subscription
    subscription if subscription&.active_access?
  end

  def can_access_analytics?
    active_subscription.present?
  end

  def analytics_plan
    active_subscription&.plan
  end
end

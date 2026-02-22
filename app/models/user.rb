class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :photo
  has_many :vehicles, dependent: :destroy

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
end

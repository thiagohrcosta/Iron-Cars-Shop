class Brand < ApplicationRecord
  belongs_to :user
  has_many :car_models, dependent: :destroy
end

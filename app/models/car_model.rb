class CarModel < ApplicationRecord
  belongs_to :brand
  belongs_to :user

  has_many :vehicles, dependent: :destroy

  enum :body_type, {
    sedan: 0,
    suv: 1,
    truck: 2,
    coupe: 3,
    hatchback: 4,
    convertible: 5,
    wagon: 6,
    van: 7,
    electric: 8,
    sports: 9
  }
end

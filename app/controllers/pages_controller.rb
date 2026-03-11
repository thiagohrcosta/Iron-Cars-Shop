class PagesController < ApplicationController
  def home
    @featured_vehicles = Vehicle
      .includes(car_model: :brand, photos_attachments: :blob)
      .order(created_at: :desc)
      .limit(3)

    @category_cards = [
      { name: "SUV", count: 52_300 },
      { name: "Sedan", count: 43_900 },
      { name: "Pickup", count: 30_100 },
      { name: "Sports", count: 18_900 },
      { name: "Electric", count: 12_500 }
    ]
  end
end

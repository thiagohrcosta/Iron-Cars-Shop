# Builds the valid users and vehicles most tests need, with unique emails,
# documents, slugs and VINs so tests never collide. Pass overrides for what a
# test actually cares about.
module RecordsTestHelper
  def create_user(email = "user-#{SecureRandom.hex(4)}@example.com", full_name = "Test User", **attributes)
    User.create!(
      email: email,
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: full_name,
      document_id: SecureRandom.random_number(10**11).to_s.rjust(11, "0"),
      phone_number: "5551212121",
      address_street: "Market St",
      address_number: "100",
      address_neighborhood: "Central",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US",
      **attributes
    )
  end

  def create_car_model(owner, body_type: :coupe)
    token = SecureRandom.hex(4)
    brand = Brand.create!(user: owner, name: "BMW #{token}", slug: "bmw-#{token}", description: "BMW", country: "Germany", founded_in: "1916")
    CarModel.create!(user: owner, brand: brand, name: "M4", slug: "m4-#{token}", description: "M4", body_type: body_type)
  end

  def create_vehicle(seller, car_model: create_car_model(seller), **attributes)
    Vehicle.create!(
      user: seller,
      car_model: car_model,
      vin: SecureRandom.random_number(10**17).to_s.rjust(17, "0"),
      year: 2024,
      mileage: 4_000,
      exterior_color: "black",
      transmission: :automatic,
      fuel_type: :gasoline,
      drivetrain: :rwd,
      condition: :used,
      title_status: :clean,
      price_cents: 5_800_000,
      currency: :usd,
      **attributes
    )
  end
end

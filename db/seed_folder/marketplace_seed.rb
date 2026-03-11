# frozen_string_literal: true

# High-volume marketplace seed.
# Usage example:
#   VEHICLES_COUNT=250000 USERS_COUNT=12000 bin/rails db:seed

vehicles_target = ENV.fetch("VEHICLES_COUNT", "250000").to_i
users_target = ENV.fetch("USERS_COUNT", "12000").to_i
batch_size = ENV.fetch("SEED_BATCH_SIZE", "5000").to_i

raise "No car models found. Run car_model_seed first." if CarModel.count.zero?

puts "Preparing marketplace seed (users=#{users_target}, vehicles=#{vehicles_target}, batch=#{batch_size})..."

VeihcleListing.delete_all
Vehicle.delete_all

admin = User.find_by(role: :admin) || User.first
raise "No user found to seed marketplace." if admin.nil?

existing_seed_users = User.where("email LIKE 'seed_user_%@ironcars.com'").count
users_to_create = [ users_target - existing_seed_users, 0 ].max

if users_to_create.positive?
  puts "Creating #{users_to_create} users..."

  now = Time.current
  user_rows = []

  users_to_create.times do |index|
    sequence = existing_seed_users + index + 1

    user_rows << {
      email: "seed_user_#{sequence}@ironcars.com",
      encrypted_password: Devise::Encryptor.digest(User, "12345678"),
      full_name: "Seed User #{sequence}",
      document_id: "#{900_000_000_00 + sequence}",
      phone_number: "+1-555-#{(10_000 + sequence).to_s[-4, 4]}",
      address_street: "Seed Street",
      address_number: (sequence % 999 + 1).to_s,
      address_complement: nil,
      address_neighborhood: "Marketplace",
      address_city: "New York",
      address_state: "NY",
      address_zip_code: "10001",
      address_country: "United States",
      role: User.roles[:user],
      created_at: now,
      updated_at: now
    }

    next unless user_rows.size >= batch_size

    User.insert_all!(user_rows)
    user_rows.clear
  end

  User.insert_all!(user_rows) if user_rows.any?
end

seller_ids = User.where(role: :user).pluck(:id)
seller_ids = [ admin.id ] if seller_ids.empty?

model_years = CarModel.pluck(:id, :production_start_date).to_h do |id, date|
  [ id, [ date&.year || 1990, Date.current.year + 1 ].min ]
end
model_ids = model_years.keys

transmissions = Vehicle.transmissions.keys
fuel_types = Vehicle.fuel_types.keys
conditions = Vehicle.conditions.values
colors = %w[black white silver gray blue red green beige]

puts "Creating #{vehicles_target} vehicles + listings..."

vin_counter = Vehicle.maximum(:vin).to_i
now = Time.current
created = 0

while created < vehicles_target
  chunk = [ batch_size, vehicles_target - created ].min
  vehicle_rows = Array.new(chunk) do |offset|
    vin_number = vin_counter + offset + 1
    car_model_id = model_ids.sample
    min_year = model_years[car_model_id]
    year = rand(min_year..(Date.current.year + 1))

    {
      vin: vin_number.to_s.rjust(17, "0"),
      car_model_id: car_model_id,
      year: year,
      mileage: rand(0..220_000),
      exterior_color: colors.sample,
      interior_color: colors.sample,
      transmission: transmissions.sample,
      fuel_type: fuel_types.sample,
      drivetrain: %w[fwd rwd awd 4wd].sample,
      engine_description: "#{rand(1.2..6.2).round(1)}L",
      mpg_city: rand(12..45),
      mpg_highway: rand(18..60),
      owners_count: rand(0..4),
      accident_count: rand(0..2),
      salvage_title: false,
      flood_damage: false,
      frame_damage: false,
      lemon_history: false,
      title_status: "clean",
      doors: [ 2, 4, 5 ].sample,
      seats: [ 2, 4, 5, 7 ].sample,
      condition: conditions.sample,
      price_cents: rand(500_000..9_500_000),
      currency: Vehicle.currencies[:usd],
      user_id: seller_ids.sample,
      created_at: now,
      updated_at: now
    }
  end

  inserted = Vehicle.insert_all!(vehicle_rows, returning: %w[id user_id]).to_a

  listing_rows = if inserted.any?
    inserted.map do |record|
      {
        vehicle_id: record["id"],
        seller_id: record["user_id"],
        status: "published",
        published_at: now,
        expires_at: now + 180.days,
        views_count: rand(0..2_000),
        featured: rand < 0.05
      }
    end
  else
    vins = vehicle_rows.map { |row| row[:vin] }
    Vehicle.where(vin: vins).pluck(:id, :user_id).map do |vehicle_id, user_id|
      {
        vehicle_id: vehicle_id,
        seller_id: user_id,
        status: "published",
        published_at: now,
        expires_at: now + 180.days,
        views_count: rand(0..2_000),
        featured: rand < 0.05
      }
    end
  end

  VeihcleListing.insert_all!(listing_rows)

  vin_counter += chunk
  created += chunk
  puts "Inserted #{created}/#{vehicles_target} vehicles"
end

puts "Marketplace seed completed: users=#{User.count}, vehicles=#{Vehicle.count}, listings=#{VeihcleListing.count}"

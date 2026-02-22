# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_22_212306) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description", null: false
    t.string "country", null: false
    t.string "founded_in", null: false
    t.boolean "active", default: true, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_brands_on_user_id"
  end

  create_table "car_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.integer "body_type", null: false
    t.date "production_start_date"
    t.date "production_end_date"
    t.boolean "active", default: true
    t.bigint "brand_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_car_models_on_brand_id"
    t.index ["user_id"], name: "index_car_models_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name", null: false
    t.string "document_id", null: false
    t.string "phone_number", null: false
    t.string "address_street", null: false
    t.string "address_number", null: false
    t.string "address_complement"
    t.string "address_neighborhood", null: false
    t.string "address_city", null: false
    t.string "address_state", null: false
    t.string "address_zip_code", null: false
    t.string "address_country", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicle_features", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.string "name", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vehicle_id", "name"], name: "index_vehicle_features_on_vehicle_id_and_name", unique: true
    t.index ["vehicle_id"], name: "index_vehicle_features_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "vin", null: false
    t.bigint "car_model_id", null: false
    t.integer "year", null: false
    t.integer "mileage", default: 0, null: false
    t.string "exterior_color"
    t.string "interior_color"
    t.string "transmission"
    t.string "fuel_type"
    t.string "drivetrain"
    t.string "engine_description"
    t.integer "mpg_city"
    t.integer "mpg_highway"
    t.integer "owners_count", default: 0
    t.integer "accident_count", default: 0
    t.boolean "salvage_title", default: false, null: false
    t.boolean "flood_damage", default: false, null: false
    t.boolean "frame_damage", default: false, null: false
    t.boolean "lemon_history", default: false, null: false
    t.string "title_status", default: "clean", null: false
    t.integer "doors"
    t.integer "seats"
    t.string "condition", null: false
    t.integer "price_cents", default: 0, null: false
    t.integer "currency", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_model_id"], name: "index_vehicles_on_car_model_id"
    t.index ["condition"], name: "index_vehicles_on_condition"
    t.index ["mileage"], name: "index_vehicles_on_mileage"
    t.index ["price_cents"], name: "index_vehicles_on_price_cents"
    t.index ["title_status"], name: "index_vehicles_on_title_status"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true
    t.index ["year"], name: "index_vehicles_on_year"
  end

  create_table "veihcle_listings", force: :cascade do |t|
    t.bigint "vehicle_id", null: false
    t.bigint "seller_id", null: false
    t.string "status", default: "draft", null: false
    t.datetime "published_at"
    t.datetime "expires_at"
    t.integer "views_count", default: 0, null: false
    t.boolean "featured", default: false, null: false
    t.index ["seller_id"], name: "index_veihcle_listings_on_seller_id"
    t.index ["vehicle_id"], name: "index_veihcle_listings_on_vehicle_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "brands", "users"
  add_foreign_key "car_models", "brands"
  add_foreign_key "car_models", "users"
  add_foreign_key "vehicle_features", "vehicles"
  add_foreign_key "vehicles", "car_models"
  add_foreign_key "vehicles", "users"
  add_foreign_key "veihcle_listings", "users", column: "seller_id"
  add_foreign_key "veihcle_listings", "vehicles"
end

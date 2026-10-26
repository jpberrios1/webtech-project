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

ActiveRecord::Schema[8.1].define(version: 2026_10_26_144008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "amenities", force: :cascade do |t|
    t.string "name", limit: 80, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "seeker_id", null: false
    t.text "message", null: false
    t.date "desired_move_in_date", null: false
    t.integer "length_of_stay_days", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "seeker_id"], name: "index_applications_on_listing_id_and_seeker_id", unique: true
    t.index ["listing_id"], name: "index_applications_on_listing_id"
    t.index ["seeker_id"], name: "index_applications_on_seeker_id"
    t.index ["status"], name: "index_applications_on_status"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "title", limit: 150, null: false
    t.string "status", default: "draft", null: false
    t.integer "minimum_stay_days"
    t.decimal "monthly_rent", precision: 10, scale: 2, null: false
    t.decimal "deposit", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "is_furnished", default: false, null: false
    t.boolean "has_private_bathroom", default: false, null: false
    t.text "description"
    t.text "house_rules"
    t.date "available_from", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_from"], name: "index_listings_on_available_from"
    t.index ["property_id"], name: "index_listings_on_property_id"
    t.index ["status"], name: "index_listings_on_status"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", limit: 120, null: false
    t.string "city", limit: 120, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "city"], name: "index_neighborhoods_on_name_and_city", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "title", limit: 150, null: false
    t.string "address", limit: 255, null: false
    t.string "property_type", default: "other", null: false
    t.integer "bedrooms", null: false
    t.integer "bathrooms", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id"], name: "index_properties_on_neighborhood_id"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
    t.index ["property_id"], name: "index_property_amenities_on_property_id"
  end

  create_table "property_shared_spaces", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "shared_space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "shared_space_id"], name: "idx_on_property_id_shared_space_id_894bc60e0e", unique: true
    t.index ["property_id"], name: "index_property_shared_spaces_on_property_id"
    t.index ["shared_space_id"], name: "index_property_shared_spaces_on_shared_space_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.bigint "reviewer_id"
    t.string "reason", null: false
    t.string "status", default: "pending", null: false
    t.text "description"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_reports_on_listing_id"
    t.index ["reviewer_id"], name: "index_reports_on_reviewer_id"
    t.index ["status"], name: "index_reports_on_status"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.bigint "property_id", null: false
    t.bigint "user_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_reviews_on_property_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.index ["visit_id"], name: "index_reviews_on_visit_id", unique: true
  end

  create_table "saved_listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_saved_listings_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_saved_listings_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_saved_listings_on_user_id"
  end

  create_table "shared_spaces", force: :cascade do |t|
    t.string "name", limit: 80, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_shared_spaces_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 120, null: false
    t.string "email_address", limit: 255, null: false
    t.string "password_digest", limit: 255, null: false
    t.string "phone", limit: 30
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", default: "proposed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_visits_on_application_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applications", "listings"
  add_foreign_key "applications", "users", column: "seeker_id"
  add_foreign_key "listings", "properties"
  add_foreign_key "properties", "neighborhoods"
  add_foreign_key "properties", "users"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "property_shared_spaces", "properties"
  add_foreign_key "property_shared_spaces", "shared_spaces"
  add_foreign_key "reports", "listings"
  add_foreign_key "reports", "users"
  add_foreign_key "reports", "users", column: "reviewer_id"
  add_foreign_key "reviews", "properties"
  add_foreign_key "reviews", "users"
  add_foreign_key "reviews", "visits"
  add_foreign_key "saved_listings", "listings"
  add_foreign_key "saved_listings", "users"
  add_foreign_key "visits", "applications"
end

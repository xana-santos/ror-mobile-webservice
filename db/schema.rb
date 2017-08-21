# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170816085622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "line_1"
    t.string   "line_2"
    t.string   "suburb"
    t.string   "state"
    t.string   "postcode"
    t.string   "address_type"
    t.datetime "deleted_at"
    t.integer  "record_id"
    t.string   "record_type"
    t.string   "api_token"
    t.boolean  "main_address", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["deleted_at"], name: "index_addresses_on_deleted_at", using: :btree
  add_index "addresses", ["record_id", "record_type"], name: "index_addresses_on_record_id_and_record_type", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_super_admin"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "appointments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "old_id",                default: "nextval('appointments_id_seq'::regclass)"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "all_day_event",         default: false
    t.boolean  "private_event",         default: false
    t.integer  "session_rate"
    t.string   "repeat_after",          default: "never"
    t.integer  "trainer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration",              default: 0
    t.string   "event_type",            default: "appointment",                              null: false
    t.text     "event_note"
    t.datetime "next_session"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.string   "start_time"
    t.string   "end_time"
    t.text     "unconverted_note"
    t.integer  "sessions_per_week"
    t.integer  "client_value_per_week"
  end

  add_index "appointments", ["api_token"], name: "index_appointments_on_api_token", using: :btree
  add_index "appointments", ["deleted_at"], name: "index_appointments_on_deleted_at", using: :btree

  create_table "authorizations", force: :cascade do |t|
    t.string   "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_products", force: :cascade do |t|
    t.integer  "product_category_id"
    t.integer  "product_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "category_products", ["product_category_id"], name: "index_category_products_on_product_category_id", using: :btree
  add_index "category_products", ["product_id"], name: "index_category_products_on_product_id", using: :btree

  create_table "client_appointments", force: :cascade do |t|
    t.integer  "old_appointment_id"
    t.integer  "client_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "client_detail_id"
    t.uuid     "appointment_id"
  end

  add_index "client_appointments", ["client_id"], name: "index_client_appointments_on_client_id", using: :btree
  add_index "client_appointments", ["old_appointment_id"], name: "index_client_appointments_on_old_appointment_id", using: :btree

  create_table "client_cards", force: :cascade do |t|
    t.integer  "client_id"
    t.string   "last_4"
    t.string   "brand"
    t.string   "country"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "client_cards", ["api_token"], name: "index_client_cards_on_api_token", using: :btree
  add_index "client_cards", ["client_id"], name: "index_client_cards_on_client_id", using: :btree
  add_index "client_cards", ["deleted_at"], name: "index_client_cards_on_deleted_at", using: :btree

  create_table "client_details", force: :cascade do |t|
    t.date     "start_date"
    t.boolean  "supplement_only"
    t.integer  "session_duration"
    t.integer  "session_rate"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "prospect_only"
    t.decimal  "num_bulk_sessions", default: 0.0
  end

  add_index "client_details", ["user_id"], name: "index_client_details_on_user_id", using: :btree

  create_table "client_sessions", force: :cascade do |t|
    t.integer  "session_id"
    t.integer  "client_id"
    t.string   "status"
    t.integer  "charge_percent", default: 100
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "api_token"
    t.datetime "deleted_at"
    t.integer  "amount"
  end

  add_index "client_sessions", ["client_id"], name: "index_client_sessions_on_client_id", using: :btree
  add_index "client_sessions", ["deleted_at"], name: "index_client_sessions_on_deleted_at", using: :btree
  add_index "client_sessions", ["session_id"], name: "index_client_sessions_on_session_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "comment"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.date     "comment_date"
    t.string   "comment_time"
  end

  add_index "comments", ["api_token"], name: "index_comments_on_api_token", using: :btree
  add_index "comments", ["deleted_at"], name: "index_comments_on_deleted_at", using: :btree

  create_table "consultations", force: :cascade do |t|
    t.float    "chest"
    t.float    "hips"
    t.float    "weight"
    t.float    "waist"
    t.float    "lean_body_weight"
    t.float    "body_fat_weight"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "image_urls",        default: "--- {}\n"
    t.float    "measurement"
    t.float    "left_arm"
    t.float    "right_arm"
    t.float    "glutes"
    t.float    "left_quads"
    t.float    "right_quads"
    t.float    "right_calf"
    t.float    "left_calf"
    t.float    "total_measurement"
    t.float    "fat_percentage"
    t.text     "comments"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.date     "consultation_date"
    t.string   "consultation_time"
  end

  add_index "consultations", ["api_token"], name: "index_consultations_on_api_token", using: :btree
  add_index "consultations", ["deleted_at"], name: "index_consultations_on_deleted_at", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "gym_locations", force: :cascade do |t|
    t.integer  "gym_id"
    t.string   "state"
    t.string   "street_address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "timezone"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "deleted_at"
    t.string   "api_token"
    t.string   "phone_number"
    t.string   "name"
    t.string   "status",         default: "Open"
    t.string   "suburb"
    t.string   "postcode"
  end

  add_index "gym_locations", ["deleted_at"], name: "index_gym_locations_on_deleted_at", using: :btree
  add_index "gym_locations", ["gym_id"], name: "index_gym_locations_on_gym_id", using: :btree
  add_index "gym_locations", ["latitude", "longitude"], name: "index_gym_locations_on_latitude_and_longitude", using: :btree

  create_table "gyms", force: :cascade do |t|
    t.string   "name"
    t.string   "api_token"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gyms", ["deleted_at"], name: "index_gyms_on_deleted_at", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "record_type"
    t.string   "url"
    t.string   "api_token"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "purpose",     default: "image"
    t.integer  "position"
  end

  add_index "images", ["record_id", "record_type"], name: "index_images_on_record_id_and_record_type", using: :btree

  create_table "invoice_items", force: :cascade do |t|
    t.integer  "record_id"
    t.string   "record_type"
    t.string   "record_token"
    t.integer  "invoice_id"
    t.integer  "quantity"
    t.string   "item"
    t.integer  "subtotal"
    t.integer  "total"
    t.integer  "fees"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_items", ["deleted_at"], name: "index_invoice_items_on_deleted_at", using: :btree
  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id", using: :btree
  add_index "invoice_items", ["record_id", "record_type"], name: "index_invoice_items_on_record_id_and_record_type", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "trainer_id"
    t.string   "record_type"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_details"
    t.boolean  "paid",            default: false
    t.integer  "record_id"
    t.string   "record_token"
    t.integer  "attempts",        default: 0
    t.string   "stripe_id"
    t.integer  "trainer_fees"
  end

  add_index "invoices", ["client_id"], name: "index_invoices_on_client_id", using: :btree
  add_index "invoices", ["deleted_at"], name: "index_invoices_on_deleted_at", using: :btree
  add_index "invoices", ["record_id", "record_type"], name: "index_invoices_on_record_id_and_record_type", using: :btree
  add_index "invoices", ["record_type"], name: "index_invoices_on_record_type", using: :btree
  add_index "invoices", ["trainer_id"], name: "index_invoices_on_trainer_id", using: :btree

  create_table "product_categories", force: :cascade do |t|
    t.string   "category"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
    t.string   "api_token"
    t.datetime "deleted_at"
  end

  create_table "product_purchases", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "purchase_id"
    t.integer  "quantity"
    t.integer  "unit_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "api_token"
    t.integer  "total"
  end

  add_index "product_purchases", ["api_token"], name: "index_product_purchases_on_api_token", using: :btree
  add_index "product_purchases", ["deleted_at"], name: "index_product_purchases_on_deleted_at", using: :btree
  add_index "product_purchases", ["product_id"], name: "index_product_purchases_on_product_id", using: :btree
  add_index "product_purchases", ["purchase_id"], name: "index_product_purchases_on_purchase_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "product_id"
    t.integer  "unit_price"
    t.string   "unit_type"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "out_of_stock",    default: false
    t.string   "custom_category"
    t.integer  "cost",            default: 0
    t.datetime "deleted_at"
    t.string   "api_token"
    t.string   "product_image"
  end

  add_index "products", ["api_token"], name: "index_products_on_api_token", using: :btree
  add_index "products", ["deleted_at"], name: "index_products_on_deleted_at", using: :btree
  add_index "products", ["product_id"], name: "index_products_on_product_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.integer  "trainer_id"
    t.integer  "client_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     default: "unconfirmed"
    t.datetime "deleted_at"
    t.string   "api_token"
  end

  add_index "purchases", ["api_token"], name: "index_purchases_on_api_token", using: :btree
  add_index "purchases", ["deleted_at"], name: "index_purchases_on_deleted_at", using: :btree

  create_table "referrals", force: :cascade do |t|
    t.integer  "referee_id"
    t.integer  "referrer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "referrals", ["referee_id"], name: "index_referrals_on_referee_id", using: :btree
  add_index "referrals", ["referrer_id"], name: "index_referrals_on_referrer_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "old_appointment_id"
    t.date     "date"
    t.string   "time"
    t.string   "api_token"
    t.integer  "session_rate"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "deleted_at"
    t.datetime "utc_datetime"
    t.uuid     "appointment_id"
  end

  add_index "sessions", ["deleted_at"], name: "index_sessions_on_deleted_at", using: :btree
  add_index "sessions", ["old_appointment_id"], name: "index_sessions_on_old_appointment_id", using: :btree

  create_table "stored_sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "stored_sessions", ["deleted_at"], name: "index_stored_sessions_on_deleted_at", using: :btree
  add_index "stored_sessions", ["session_id"], name: "index_stored_sessions_on_session_id", unique: true, using: :btree
  add_index "stored_sessions", ["updated_at"], name: "index_stored_sessions_on_updated_at", using: :btree

  create_table "stripe_details", force: :cascade do |t|
    t.string   "secret_key"
    t.string   "publishable_key"
    t.integer  "trainer_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "stripe_details", ["trainer_id"], name: "index_stripe_details_on_trainer_id", using: :btree

  create_table "trainer_gyms", force: :cascade do |t|
    t.integer  "gym_location_id"
    t.integer  "trainer_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "trainer_gyms", ["gym_location_id"], name: "index_trainer_gyms_on_gym_location_id", using: :btree

  create_table "trainer_identifications", force: :cascade do |t|
    t.string   "code"
    t.text     "details"
    t.string   "status",     default: "unverified"
    t.string   "token"
    t.integer  "trainer_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "trainer_identifications", ["trainer_id"], name: "index_trainer_identifications_on_trainer_id", using: :btree

  create_table "trainer_targets", force: :cascade do |t|
    t.integer  "trainer_id"
    t.integer  "earning"
    t.integer  "supplement_sales"
    t.integer  "work_hours"
    t.datetime "date"
    t.integer  "holidays"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "api_token"
  end

  add_index "trainer_targets", ["trainer_id"], name: "index_trainer_targets_on_trainer_id", using: :btree

  create_table "trainer_verifications", force: :cascade do |t|
    t.string   "disabled_reason"
    t.integer  "due_by"
    t.text     "fields_needed",   default: [],                        array: true
    t.integer  "trainer_id"
    t.string   "status",          default: "unverified"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "trainer_verifications", ["trainer_id"], name: "index_trainer_verifications_on_trainer_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin",            default: false
    t.string   "reset_token"
    t.datetime "reset_sent"
    t.string   "api_token"
    t.string   "type"
    t.datetime "deleted_at"
    t.string   "mobile"
    t.string   "office"
    t.string   "phone"
    t.string   "abn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",           default: true
    t.integer  "trainer_id"
    t.date     "birthdate"
    t.string   "stripe_id"
    t.boolean  "mobile_preferred", default: false
    t.string   "bank_last_4"
    t.boolean  "terms_accepted",   default: false
    t.boolean  "gst",              default: true
    t.string   "pflo_stripe_id"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["trainer_id"], name: "index_users_on_trainer_id", using: :btree

  add_foreign_key "client_details", "users"
end

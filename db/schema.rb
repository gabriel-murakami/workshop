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

ActiveRecord::Schema[7.2].define(version: 2025_08_09_214743) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "budgets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "service_order_id", null: false
    t.date "date", null: false
    t.decimal "total_value", precision: 12, scale: 2, default: "0.0", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_order_id"], name: "index_budgets_on_service_order_id", unique: true
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "document_number", null: false
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_number"], name: "index_customers_on_document_number", unique: true
  end

  create_table "metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "service_order_count", default: 0
    t.decimal "average_time", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "stock_quantity", default: 0, null: false
    t.decimal "base_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sku", null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "service_order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "service_order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "total_value", precision: 12, scale: 2, default: "0.0", null: false
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_service_order_items_on_item"
    t.index ["service_order_id"], name: "index_service_order_items_on_service_order_id"
  end

  create_table "service_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.uuid "vehicle_id", null: false
    t.datetime "service_started_at"
    t.datetime "service_finished_at"
    t.string "status", default: "received", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_service_orders_on_customer_id"
    t.index ["vehicle_id"], name: "index_service_orders_on_vehicle_id"
  end

  create_table "services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "base_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", null: false
    t.index ["code"], name: "index_services_on_code", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id"
    t.string "license_plate", null: false
    t.string "brand"
    t.string "model"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
  end

  add_foreign_key "budgets", "service_orders"
  add_foreign_key "service_order_items", "service_orders"
  add_foreign_key "service_orders", "customers"
  add_foreign_key "service_orders", "vehicles"
  add_foreign_key "vehicles", "customers"
end

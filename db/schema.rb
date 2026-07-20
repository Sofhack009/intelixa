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

ActiveRecord::Schema[8.0].define(version: 2026_07_20_112521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "inventory_batches", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "warehouse_id", null: false
    t.string "batch_number", null: false
    t.integer "quantity", default: 0, null: false
    t.decimal "unit_cost", precision: 12, scale: 2, null: false
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_inventory_batches_on_item_id"
    t.index ["warehouse_id"], name: "index_inventory_batches_on_warehouse_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "sku_code", null: false
    t.string "name", null: false
    t.string "category"
    t.string "item_type", null: false
    t.string "hsn_code"
    t.integer "min_stock_level", default: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku_code"], name: "index_items_on_sku_code", unique: true
  end

  create_table "job_work_challans", force: :cascade do |t|
    t.bigint "job_worker_id", null: false
    t.datetime "issued_date", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "expected_return_date", null: false
    t.string "status", default: "Pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_worker_id"], name: "index_job_work_challans_on_job_worker_id"
  end

  create_table "job_work_items", force: :cascade do |t|
    t.bigint "job_work_challan_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity_issued", null: false
    t.integer "quantity_received", default: 0
    t.integer "quantity_scrapped", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_job_work_items_on_item_id"
    t.index ["job_work_challan_id"], name: "index_job_work_items_on_job_work_challan_id"
  end

  create_table "job_workers", force: :cascade do |t|
    t.string "name", null: false
    t.string "process_type", null: false
    t.decimal "rate_per_unit", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quality_inspections", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity_inspected", null: false
    t.integer "quantity_approved", null: false
    t.integer "quantity_rejected", null: false
    t.integer "inspected_by"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_quality_inspections_on_item_id"
    t.index ["source_type", "source_id"], name: "index_quality_inspections_on_source"
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wastage_logs", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "quantity_wasted", null: false
    t.string "reason_code", null: false
    t.decimal "estimated_cost", precision: 10, scale: 2, null: false
    t.datetime "logged_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_wastage_logs_on_item_id"
  end

  add_foreign_key "inventory_batches", "items"
  add_foreign_key "inventory_batches", "warehouses"
  add_foreign_key "job_work_challans", "job_workers"
  add_foreign_key "job_work_items", "items"
  add_foreign_key "job_work_items", "job_work_challans"
  add_foreign_key "quality_inspections", "items"
  add_foreign_key "wastage_logs", "items"
end

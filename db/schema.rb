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

ActiveRecord::Schema[8.1].define(version: 2026_10_14_000000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
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
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_categories_on_active_and_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "email"
    t.string "zip_code"
    t.string "street"
    t.string "number"
    t.string "neighborhood"
    t.string "city"
    t.string "state", limit: 2
    t.string "complement"
    t.string "reference"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_customers_on_name"
    t.index ["phone"], name: "index_customers_on_phone", unique: true
  end

  create_table "delivery_areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.decimal "fee", precision: 10, scale: 2, default: "0.0", null: false
    t.string "estimated_time"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_delivery_areas_on_active"
    t.index ["slug"], name: "index_delivery_areas_on_slug", unique: true
  end

  create_table "discounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "discount_type", null: false
    t.decimal "value", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "minimum_order_value", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer "usage_limit"
    t.integer "uses_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "starts_at", "ends_at"], name: "index_discounts_on_active_and_starts_at_and_ends_at"
    t.index ["code"], name: "index_discounts_on_code", unique: true
  end

  create_table "financial_entries", force: :cascade do |t|
    t.integer "order_id"
    t.string "entry_type", null: false
    t.string "status", default: "pending", null: false
    t.string "description", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "due_date"
    t.date "paid_at"
    t.boolean "automatic", default: false, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_type", "status", "due_date"], name: "index_financial_entries_on_entry_type_and_status_and_due_date"
    t.index ["order_id"], name: "index_financial_entries_on_order_id"
  end

  create_table "financial_entry_items", force: :cascade do |t|
    t.integer "financial_entry_id", null: false
    t.integer "product_id", null: false
    t.integer "product_variant_id"
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["financial_entry_id"], name: "index_financial_entry_items_on_financial_entry_id"
    t.index ["product_id"], name: "index_financial_entry_items_on_product_id"
    t.index ["product_variant_id"], name: "index_financial_entry_items_on_product_variant_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id"
    t.integer "product_variant_id"
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "promotion_gift", default: false, null: false
    t.boolean "surprise_gift", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "delivery_area_id"
    t.integer "discount_id"
    t.integer "promotion_id"
    t.string "number", null: false
    t.string "status", default: "pending", null: false
    t.string "fulfillment_method", default: "pickup", null: false
    t.string "payment_method", default: "pix", null: false
    t.decimal "change_for", precision: 10, scale: 2
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "delivery_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.text "delivery_address"
    t.text "notes"
    t.boolean "stock_deducted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["delivery_area_id"], name: "index_orders_on_delivery_area_id"
    t.index ["discount_id"], name: "index_orders_on_discount_id"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["promotion_id"], name: "index_orders_on_promotion_id"
    t.index ["status", "created_at"], name: "index_orders_on_status_and_created_at"
  end

  create_table "personal_financial_entries", force: :cascade do |t|
    t.string "description", null: false
    t.string "entry_type", null: false
    t.string "responsible", null: false
    t.string "category"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "due_date", null: false
    t.date "paid_at"
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "due_date"], name: "index_personal_financial_entries_on_status_and_due_date"
  end

  create_table "product_images", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "title"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "position"], name: "index_product_images_on_product_id_and_position"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2
    t.boolean "active", default: true, null: false
    t.integer "quantity", default: 0, null: false
    t.integer "low_stock_threshold", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "active"], name: "index_product_variants_on_product_id_and_active"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.boolean "featured", default: false, null: false
    t.boolean "track_inventory", default: false, null: false
    t.integer "quantity", default: 0, null: false
    t.integer "low_stock_threshold", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "active", "position"], name: "index_products_on_category_id_and_active_and_position"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "promotions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "required_quantity", null: false
    t.integer "gift_quantity", default: 0, null: false
    t.boolean "surprise_gift", default: false, null: false
    t.boolean "free_shipping", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_promotions_on_active_and_position"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_variant_id"
    t.integer "order_id"
    t.integer "quantity", null: false
    t.string "movement_type", null: false
    t.string "reason", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_stock_movements_on_order_id"
    t.index ["product_id", "created_at"], name: "index_stock_movements_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["product_variant_id", "created_at"], name: "index_stock_movements_on_product_variant_id_and_created_at"
    t.index ["product_variant_id"], name: "index_stock_movements_on_product_variant_id"
  end

  create_table "store_settings", force: :cascade do |t|
    t.string "singleton_key", default: "current", null: false
    t.string "store_name", default: "Delícias da Tia Nely", null: false
    t.string "whatsapp_number"
    t.string "pix_key"
    t.text "address"
    t.text "business_hours"
    t.text "order_message"
    t.decimal "minimum_order_value", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "default_delivery_fee", precision: 10, scale: 2, default: "10.0", null: false
    t.text "pickup_policy"
    t.string "instagram_url"
    t.string "facebook_url"
    t.boolean "accepting_orders", default: false, null: false
    t.text "pause_message", default: "No momento não estamos recebendo pedidos. Voltamos em breve.", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["singleton_key"], name: "index_store_settings_on_singleton_key", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "financial_entries", "orders"
  add_foreign_key "financial_entry_items", "financial_entries"
  add_foreign_key "financial_entry_items", "product_variants"
  add_foreign_key "financial_entry_items", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "delivery_areas"
  add_foreign_key "orders", "discounts"
  add_foreign_key "orders", "promotions"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "stock_movements", "orders"
  add_foreign_key "stock_movements", "product_variants"
  add_foreign_key "stock_movements", "products"
end

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

ActiveRecord::Schema.define(version: 20171129093652) do

  create_table "adjustments", force: :cascade do |t|
    t.integer  "adjustable_id",   limit: 4
    t.string   "adjustable_type", limit: 255
    t.integer  "source_id",       limit: 4
    t.string   "source_type",     limit: 255
    t.string   "label",           limit: 255
    t.integer  "amount_cents",    limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "adjustments", ["adjustable_type", "adjustable_id"], name: "index_adjustments_on_adjustable_type_and_adjustable_id", using: :btree
  add_index "adjustments", ["source_type", "source_id"], name: "index_adjustments_on_source_type_and_source_id", using: :btree

  create_table "albums", force: :cascade do |t|
    t.integer  "store_id",    limit: 4,     null: false
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "albums", ["store_id"], name: "index_albums_on_store_id", using: :btree

  create_table "albums_pages", id: false, force: :cascade do |t|
    t.integer "album_id", limit: 4, null: false
    t.integer "page_id",  limit: 4, null: false
  end

  add_index "albums_pages", ["page_id", "album_id"], name: "index_albums_pages_on_page_id_and_album_id", unique: true, using: :btree

  create_table "alternate_prices", force: :cascade do |t|
    t.integer  "group_id",    limit: 4, null: false
    t.integer  "product_id",  limit: 4, null: false
    t.integer  "price_cents", limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "alternate_prices", ["group_id"], name: "index_alternate_prices_on_group_id", using: :btree
  add_index "alternate_prices", ["product_id"], name: "index_alternate_prices_on_product_id", using: :btree

  create_table "asset_entries", force: :cascade do |t|
    t.integer  "customer_asset_id", limit: 4,   null: false
    t.date     "recorded_at"
    t.integer  "source_id",         limit: 4
    t.string   "source_type",       limit: 255
    t.integer  "amount",            limit: 4,   null: false
    t.integer  "value_cents",       limit: 4,   null: false
    t.string   "note",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "asset_entries", ["customer_asset_id"], name: "index_asset_entries_on_customer_asset_id", using: :btree
  add_index "asset_entries", ["source_type", "source_id"], name: "index_asset_entries_on_source_type_and_source_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "store_id",       limit: 4,                              null: false
    t.integer  "parent_id",      limit: 4
    t.integer  "lft",            limit: 4
    t.integer  "rgt",            limit: 4
    t.integer  "depth",          limit: 4,     default: 0,              null: false
    t.integer  "children_count", limit: 4,     default: 0,              null: false
    t.boolean  "live",                         default: true,           null: false
    t.string   "name",           limit: 255
    t.text     "subtitle",       limit: 65535
    t.string   "slug",           limit: 255,                            null: false
    t.string   "product_scope",  limit: 255
    t.boolean  "filtering",                    default: false,          null: false
    t.string   "view_mode",      limit: 255,   default: "product-grid", null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "categories", ["depth"], name: "index_categories_on_depth", using: :btree
  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree
  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree
  add_index "categories", ["store_id"], name: "index_categories_on_store_id", using: :btree

  create_table "categories_departments", id: false, force: :cascade do |t|
    t.integer "category_id",   limit: 4, null: false
    t.integer "department_id", limit: 4, null: false
  end

  add_index "categories_departments", ["category_id", "department_id"], name: "index_categories_departments_on_category_id_and_department_id", unique: true, using: :btree

  create_table "categories_groups", id: false, force: :cascade do |t|
    t.integer "category_id", limit: 4, null: false
    t.integer "group_id",    limit: 4, null: false
  end

  add_index "categories_groups", ["group_id"], name: "index_categories_groups_on_group_id", using: :btree

  create_table "categories_products", id: false, force: :cascade do |t|
    t.integer "category_id", limit: 4, null: false
    t.integer "product_id",  limit: 4, null: false
  end

  add_index "categories_products", ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id", unique: true, using: :btree

  create_table "component_entries", force: :cascade do |t|
    t.integer  "product_id",   limit: 4,             null: false
    t.integer  "component_id", limit: 4,             null: false
    t.integer  "quantity",     limit: 4, default: 1, null: false
    t.integer  "priority",     limit: 4, default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "component_entries", ["product_id"], name: "index_component_entries_on_product_id", using: :btree

  create_table "countries", id: false, force: :cascade do |t|
    t.string "code", limit: 2,   null: false
    t.string "name", limit: 255
  end

  add_index "countries", ["code"], name: "index_countries_on_code", unique: true, using: :btree

  create_table "customer_assets", force: :cascade do |t|
    t.integer  "store_id",    limit: 4,             null: false
    t.integer  "user_id",     limit: 4,             null: false
    t.integer  "product_id",  limit: 4,             null: false
    t.integer  "amount",      limit: 4, default: 0, null: false
    t.integer  "value_cents", limit: 4, default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "customer_assets", ["product_id"], name: "index_customer_assets_on_product_id", using: :btree
  add_index "customer_assets", ["store_id"], name: "index_customer_assets_on_store_id", using: :btree
  add_index "customer_assets", ["user_id"], name: "index_customer_assets_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "departments", force: :cascade do |t|
    t.integer  "store_id",   limit: 4
    t.string   "name",       limit: 255
    t.string   "slug",       limit: 255
    t.integer  "priority",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "departments", ["store_id"], name: "index_departments_on_store_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "store_id",           limit: 4,                                               null: false
    t.string   "name",               limit: 255,                                             null: false
    t.integer  "price_base",         limit: 4,                           default: 1,         null: false
    t.decimal  "price_modifier",                 precision: 5, scale: 2, default: 0.0,       null: false
    t.boolean  "price_tax_included",                                     default: true,      null: false
    t.string   "appearance",         limit: 255,                         default: "default", null: false
    t.integer  "priority",           limit: 4,                           default: 0,         null: false
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
  end

  add_index "groups", ["store_id"], name: "index_groups_on_store_id", using: :btree

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id", limit: 4, null: false
    t.integer "user_id",  limit: 4, null: false
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree

  create_table "hostnames", force: :cascade do |t|
    t.integer  "store_id",           limit: 4,               null: false
    t.integer  "parent_hostname_id", limit: 4
    t.string   "fqdn",               limit: 255,             null: false
    t.integer  "priority",           limit: 4,   default: 0, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "hostnames", ["fqdn"], name: "index_hostnames_on_fqdn", using: :btree
  add_index "hostnames", ["parent_hostname_id"], name: "index_hostnames_on_parent_hostname_id", using: :btree
  add_index "hostnames", ["store_id"], name: "index_hostnames_on_store_id", using: :btree

  create_table "iframes", force: :cascade do |t|
    t.integer  "product_id", limit: 4
    t.text     "html",       limit: 65535
    t.integer  "priority",   limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "iframes", ["product_id"], name: "index_iframes_on_product_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id",            limit: 4
    t.string   "imageable_type",          limit: 255
    t.integer  "purpose",                 limit: 4,               null: false
    t.integer  "priority",                limit: 4,   default: 0, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer  "store_id",       limit: 4
    t.boolean  "fuzzy",                      default: false, null: false
    t.string   "name",           limit: 255
    t.string   "inventory_code", limit: 255
    t.integer  "priority",       limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "inventories", ["store_id"], name: "index_inventories_on_store_id", using: :btree

  create_table "inventory_entries", force: :cascade do |t|
    t.integer  "inventory_item_id", limit: 4,   null: false
    t.date     "recorded_at"
    t.integer  "source_id",         limit: 4
    t.string   "source_type",       limit: 255
    t.integer  "on_hand",           limit: 4,   null: false
    t.integer  "reserved",          limit: 4,   null: false
    t.integer  "pending",           limit: 4,   null: false
    t.integer  "value_cents",       limit: 4,   null: false
    t.string   "note",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "inventory_entries", ["inventory_item_id"], name: "index_inventory_entries_on_inventory_item_id", using: :btree
  add_index "inventory_entries", ["recorded_at"], name: "index_inventory_entries_on_recorded_at", using: :btree
  add_index "inventory_entries", ["source_type", "source_id"], name: "index_inventory_entries_on_source_type_and_source_id", using: :btree

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "inventory_id", limit: 4,   null: false
    t.integer  "product_id",   limit: 4,   null: false
    t.string   "code",         limit: 255, null: false
    t.integer  "on_hand",      limit: 4
    t.integer  "reserved",     limit: 4
    t.integer  "pending",      limit: 4
    t.integer  "value_cents",  limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "inventory_items", ["inventory_id"], name: "index_inventory_items_on_inventory_id", using: :btree
  add_index "inventory_items", ["product_id"], name: "index_inventory_items_on_product_id", using: :btree

  create_table "linked_products_products", id: false, force: :cascade do |t|
    t.integer "product_id",        limit: 4, null: false
    t.integer "linked_product_id", limit: 4, null: false
  end

  add_index "linked_products_products", ["product_id", "linked_product_id"], name: "linked_products_by_product", unique: true, using: :btree

  create_table "measurement_units", force: :cascade do |t|
    t.integer  "base_unit_id", limit: 4
    t.integer  "exponent",     limit: 4
    t.string   "name",         limit: 255, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "measurement_units", ["base_unit_id"], name: "index_measurement_units_on_base_unit_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "parent_item_id",        limit: 4
    t.integer  "order_id",              limit: 4,                                           null: false
    t.integer  "product_id",            limit: 4,                                           null: false
    t.string   "label",                 limit: 255
    t.integer  "amount",                limit: 4
    t.integer  "price_cents",           limit: 4
    t.decimal  "tax_rate",                          precision: 5, scale: 2, default: 0.0,   null: false
    t.boolean  "price_includes_tax",                                        default: false, null: false
    t.integer  "priority",              limit: 4
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "product_code",          limit: 255
    t.string   "product_customer_code", limit: 255
    t.string   "product_title",         limit: 255
    t.string   "product_subtitle",      limit: 255
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["parent_item_id"], name: "index_order_items_on_parent_item_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "order_report_rows", force: :cascade do |t|
    t.integer  "order_type_id",         limit: 4, null: false
    t.integer  "user_id",               limit: 4
    t.string   "shipping_country_code", limit: 2
    t.integer  "product_id",            limit: 4, null: false
    t.date     "ordered_at",                      null: false
    t.integer  "amount",                limit: 4, null: false
    t.integer  "total_value_cents",     limit: 4, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "order_report_rows", ["order_type_id"], name: "index_order_report_rows_on_order_type_id", using: :btree
  add_index "order_report_rows", ["ordered_at"], name: "index_order_report_rows_on_ordered_at", using: :btree
  add_index "order_report_rows", ["product_id"], name: "index_order_report_rows_on_product_id", using: :btree
  add_index "order_report_rows", ["shipping_country_code"], name: "index_order_report_rows_on_shipping_country_code", using: :btree
  add_index "order_report_rows", ["user_id"], name: "index_order_report_rows_on_user_id", using: :btree

  create_table "order_types", force: :cascade do |t|
    t.integer  "store_id",         limit: 4
    t.integer  "source_id",        limit: 4,                   null: false
    t.integer  "destination_id",   limit: 4,                   null: false
    t.string   "name",             limit: 255
    t.string   "label",            limit: 255
    t.boolean  "has_shipping",                 default: false, null: false
    t.boolean  "has_installation",             default: false, null: false
    t.boolean  "has_payment",                  default: false, null: false
    t.string   "payment_gateway",  limit: 255
    t.boolean  "prepaid_stock",                default: false, null: false
    t.boolean  "is_rfq",                       default: false, null: false
    t.boolean  "is_quote",                     default: false, null: false
    t.boolean  "is_exported",                  default: false, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "order_types", ["destination_id"], name: "index_order_types_on_destination_id", using: :btree
  add_index "order_types", ["source_id"], name: "index_order_types_on_source_id", using: :btree
  add_index "order_types", ["store_id"], name: "index_order_types_on_store_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "store_id",              limit: 4,                     null: false
    t.integer  "order_items_count",     limit: 4
    t.string   "number",                limit: 255
    t.string   "external_number",       limit: 255
    t.string   "vat_number",            limit: 255
    t.string   "your_reference",        limit: 255
    t.string   "our_reference",         limit: 255
    t.string   "message",               limit: 255
    t.integer  "user_id",               limit: 4,                     null: false
    t.integer  "order_type_id",         limit: 4
    t.boolean  "includes_tax",                        default: true,  null: false
    t.datetime "completed_at"
    t.date     "shipping_at"
    t.date     "installation_at"
    t.date     "approved_at"
    t.date     "concluded_at"
    t.string   "customer_name",         limit: 255
    t.string   "customer_email",        limit: 255
    t.string   "customer_phone",        limit: 255
    t.string   "company_name",          limit: 255
    t.string   "contact_person",        limit: 255
    t.string   "contact_email",         limit: 255
    t.string   "contact_phone",         limit: 255
    t.boolean  "has_billing_address",                 default: false, null: false
    t.string   "billing_address",       limit: 255
    t.string   "billing_postalcode",    limit: 255
    t.string   "billing_city",          limit: 255
    t.string   "billing_country_code",  limit: 2
    t.string   "shipping_address",      limit: 255
    t.string   "shipping_postalcode",   limit: 255
    t.string   "shipping_city",         limit: 255
    t.string   "shipping_country_code", limit: 2
    t.text     "notes",                 limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.datetime "cancelled_at"
    t.string   "store_name",            limit: 255
    t.string   "user_name",             limit: 255
    t.string   "user_email",            limit: 255
    t.string   "user_phone",            limit: 255
    t.string   "order_type_name",       limit: 255
  end

  add_index "orders", ["order_type_id"], name: "index_orders_on_order_type_id", using: :btree
  add_index "orders", ["store_id"], name: "index_orders_on_store_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "store_id",       limit: 4,                    null: false
    t.integer  "purpose",        limit: 4,     default: 1,    null: false
    t.string   "resource_type",  limit: 255
    t.integer  "resource_id",    limit: 4
    t.integer  "parent_id",      limit: 4
    t.integer  "lft",            limit: 4
    t.integer  "rgt",            limit: 4
    t.integer  "depth",          limit: 4,     default: 0,    null: false
    t.integer  "children_count", limit: 4,     default: 0,    null: false
    t.boolean  "live",                         default: true, null: false
    t.string   "title",          limit: 255
    t.string   "slug",           limit: 255,                  null: false
    t.text     "metadata",       limit: 65535
    t.text     "content",        limit: 65535
    t.boolean  "wysiwyg",                      default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "pages", ["depth"], name: "index_pages_on_depth", using: :btree
  add_index "pages", ["lft"], name: "index_pages_on_lft", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["rgt"], name: "index_pages_on_rgt", using: :btree
  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree
  add_index "pages", ["store_id"], name: "index_pages_on_store_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",     limit: 4,   null: false
    t.string   "number",       limit: 255
    t.integer  "amount_cents", limit: 4,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree

  create_table "product_properties", force: :cascade do |t|
    t.integer  "product_id",  limit: 4,                            null: false
    t.integer  "property_id", limit: 4,                            null: false
    t.string   "value",       limit: 255,                          null: false
    t.integer  "value_i",     limit: 8
    t.decimal  "value_f",                 precision: 10, scale: 2
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "product_properties", ["product_id"], name: "index_product_properties_on_product_id", using: :btree
  add_index "product_properties", ["property_id"], name: "index_product_properties_on_property_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "store_id",                limit: 4,                     null: false
    t.integer  "vendor_id",               limit: 4
    t.integer  "purpose",                 limit: 4,     default: 0,     null: false
    t.integer  "master_product_id",       limit: 4
    t.integer  "primary_variant_id",      limit: 4
    t.boolean  "live",                                  default: false, null: false
    t.string   "code",                    limit: 255
    t.string   "customer_code",           limit: 255
    t.string   "title",                   limit: 255
    t.string   "slug",                    limit: 255,                   null: false
    t.string   "subtitle",                limit: 255
    t.text     "description",             limit: 65535
    t.text     "overview",                limit: 65535
    t.text     "memo",                    limit: 65535
    t.integer  "mass",                    limit: 4
    t.integer  "dimension_u",             limit: 4
    t.integer  "dimension_v",             limit: 4
    t.integer  "dimension_w",             limit: 4
    t.string   "lead_time",               limit: 255
    t.text     "shipping_notes",          limit: 65535
    t.integer  "cost_price_cents",        limit: 4
    t.date     "cost_price_modified_at"
    t.integer  "trade_price_cents",       limit: 4
    t.date     "trade_price_modified_at"
    t.integer  "retail_price_cents",      limit: 4
    t.integer  "tax_category_id",         limit: 4,                     null: false
    t.integer  "priority",                limit: 4,     default: 0,     null: false
    t.date     "available_at"
    t.date     "deleted_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "products", ["code"], name: "index_products_on_code", using: :btree
  add_index "products", ["master_product_id"], name: "index_products_on_master_product_id", using: :btree
  add_index "products", ["purpose"], name: "index_products_on_purpose", using: :btree
  add_index "products", ["slug"], name: "index_products_on_slug", using: :btree
  add_index "products", ["store_id"], name: "index_products_on_store_id", using: :btree
  add_index "products", ["subtitle"], name: "index_products_on_subtitle", using: :btree
  add_index "products", ["tax_category_id"], name: "index_products_on_tax_category_id", using: :btree
  add_index "products", ["title"], name: "index_products_on_title", using: :btree
  add_index "products", ["vendor_id"], name: "index_products_on_vendor_id", using: :btree

  create_table "products_shipping_methods", id: false, force: :cascade do |t|
    t.integer "product_id",         limit: 4, null: false
    t.integer "shipping_method_id", limit: 4, null: false
  end

  add_index "products_shipping_methods", ["product_id"], name: "index_products_shipping_methods_on_product_id", using: :btree

  create_table "promoted_items", force: :cascade do |t|
    t.integer  "promotion_id",     limit: 4,                                     null: false
    t.integer  "product_id",       limit: 4,                                     null: false
    t.integer  "price_cents",      limit: 4
    t.decimal  "discount_percent",           precision: 5, scale: 2
    t.integer  "amount_available", limit: 4
    t.integer  "amount_sold",      limit: 4,                         default: 0, null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "promoted_items", ["price_cents"], name: "index_promoted_items_on_price_cents", using: :btree
  add_index "promoted_items", ["product_id"], name: "index_promoted_items_on_product_id", using: :btree
  add_index "promoted_items", ["promotion_id"], name: "index_promoted_items_on_promotion_id", using: :btree

  create_table "promotion_handlers", force: :cascade do |t|
    t.integer  "promotion_id",      limit: 4,   null: false
    t.string   "type",              limit: 255, null: false
    t.string   "description",       limit: 255
    t.integer  "order_total_cents", limit: 4
    t.integer  "required_items",    limit: 4
    t.integer  "items_total_cents", limit: 4
    t.integer  "discount_percent",  limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "promotion_handlers", ["promotion_id"], name: "index_promotion_handlers_on_promotion_id", using: :btree

  create_table "promotions", force: :cascade do |t|
    t.integer  "store_id",               limit: 4,                   null: false
    t.integer  "group_id",               limit: 4,                   null: false
    t.string   "promotion_handler_type", limit: 255,                 null: false
    t.boolean  "live",                               default: false, null: false
    t.string   "name",                   limit: 255
    t.string   "slug",                   limit: 255,                 null: false
    t.date     "first_date"
    t.date     "last_date"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "promotions", ["group_id"], name: "index_promotions_on_group_id", using: :btree
  add_index "promotions", ["slug"], name: "index_promotions_on_slug", using: :btree
  add_index "promotions", ["store_id"], name: "index_promotions_on_store_id", using: :btree

  create_table "properties", force: :cascade do |t|
    t.integer  "store_id",            limit: 4,                   null: false
    t.integer  "value_type",          limit: 4,                   null: false
    t.integer  "measurement_unit_id", limit: 4
    t.boolean  "unit_pricing",                    default: false, null: false
    t.boolean  "searchable",                      default: false, null: false
    t.string   "name",                limit: 255
    t.integer  "priority",            limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "properties", ["measurement_unit_id"], name: "index_properties_on_measurement_unit_id", using: :btree
  add_index "properties", ["store_id"], name: "index_properties_on_store_id", using: :btree

  create_table "requisite_entries", force: :cascade do |t|
    t.integer "product_id",   limit: 4,             null: false
    t.integer "requisite_id", limit: 4,             null: false
    t.integer "priority",     limit: 4, default: 0, null: false
  end

  add_index "requisite_entries", ["product_id"], name: "index_requisite_entries_on_product_id", using: :btree
  add_index "requisite_entries", ["requisite_id"], name: "index_requisite_entries_on_requisite_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sections", force: :cascade do |t|
    t.integer  "page_id",          limit: 4,                       null: false
    t.string   "width",            limit: 255, default: "col-12",  null: false
    t.integer  "outline",          limit: 4,   default: 1,         null: false
    t.string   "layout",           limit: 255, default: "twelve",  null: false
    t.string   "shape",            limit: 255
    t.string   "background_color", limit: 255, default: "#FFFFFF", null: false
    t.integer  "priority",         limit: 4,   default: 0,         null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "sections", ["page_id"], name: "index_sections_on_page_id", using: :btree

  create_table "segments", force: :cascade do |t|
    t.integer  "section_id",    limit: 4,                           null: false
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.integer  "template",      limit: 4,     default: 0,           null: false
    t.string   "alignment",     limit: 255,   default: "align-top", null: false
    t.text     "body",          limit: 65535
    t.text     "metadata",      limit: 65535
    t.integer  "priority",      limit: 4,     default: 0,           null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "segments", ["resource_type", "resource_id"], name: "index_segments_on_resource_type_and_resource_id", using: :btree
  add_index "segments", ["section_id"], name: "index_segments_on_section_id", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id",           limit: 4,     null: false
    t.integer  "shipping_method_id", limit: 4
    t.string   "number",             limit: 255
    t.datetime "shipped_at"
    t.datetime "cancelled_at"
    t.text     "metadata",           limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "shipments", ["order_id"], name: "index_shipments_on_order_id", using: :btree

  create_table "shipping_methods", force: :cascade do |t|
    t.integer  "store_id",                 limit: 4,     null: false
    t.string   "name",                     limit: 255,   null: false
    t.string   "shipping_gateway",         limit: 255
    t.integer  "delivery_time",            limit: 4
    t.date     "enabled_at"
    t.date     "disabled_at"
    t.text     "description",              limit: 65535
    t.integer  "shipping_cost_product_id", limit: 4
    t.integer  "free_shipping_from_cents", limit: 4
    t.integer  "detail_page_id",           limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "shipping_methods", ["store_id"], name: "index_shipping_methods_on_store_id", using: :btree

  create_table "stores", force: :cascade do |t|
    t.integer  "erp_number",       limit: 4
    t.boolean  "portal",                         default: false, null: false
    t.string   "name",             limit: 255
    t.string   "slug",             limit: 255
    t.integer  "default_group_id", limit: 4
    t.string   "country_code",     limit: 2,                     null: false
    t.text     "settings",         limit: 65535
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "tax_categories", force: :cascade do |t|
    t.integer  "store_id",           limit: 4
    t.string   "name",               limit: 255
    t.decimal  "rate",                           precision: 5, scale: 2
    t.boolean  "included_in_retail",                                     default: true, null: false
    t.integer  "priority",           limit: 4,                           default: 0,    null: false
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
  end

  add_index "tax_categories", ["store_id"], name: "index_tax_categories_on_store_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "phone",                  limit: 255
    t.string   "billing_address",        limit: 255
    t.string   "billing_postalcode",     limit: 255
    t.string   "billing_city",           limit: 255
    t.string   "billing_country_code",   limit: 2
    t.string   "shipping_address",       limit: 255
    t.string   "shipping_postalcode",    limit: 255
    t.string   "shipping_city",          limit: 255
    t.string   "shipping_country_code",  limit: 2
    t.string   "locale",                 limit: 255
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end

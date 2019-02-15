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

ActiveRecord::Schema.define(version: 20190215122741) do

  create_table "activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                    null: false
    t.integer  "user_id",                     null: false
    t.string   "action"
    t.integer  "resource_id",                 null: false
    t.string   "resource_type",               null: false
    t.integer  "context_id",                  null: false
    t.string   "context_type",                null: false
    t.text     "differences",   limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["context_type", "context_id"], name: "index_activities_on_context_type_and_context_id", using: :btree
    t.index ["store_id"], name: "index_activities_on_store_id", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "adjustments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "adjustable_id"
    t.string   "adjustable_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.string   "label"
    t.integer  "amount_cents"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["adjustable_type", "adjustable_id"], name: "index_adjustments_on_adjustable_type_and_adjustable_id", using: :btree
    t.index ["source_type", "source_id"], name: "index_adjustments_on_source_type_and_source_id", using: :btree
  end

  create_table "albums", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                  null: false
    t.string   "title"
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["store_id"], name: "index_albums_on_store_id", using: :btree
  end

  create_table "alternate_prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "group_id",    null: false
    t.integer  "product_id",  null: false
    t.integer  "price_cents", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id"], name: "index_alternate_prices_on_group_id", using: :btree
    t.index ["product_id"], name: "index_alternate_prices_on_product_id", using: :btree
  end

  create_table "asset_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "customer_asset_id", null: false
    t.date     "recorded_at"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "amount",            null: false
    t.integer  "value_cents",       null: false
    t.string   "note"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["customer_asset_id"], name: "index_asset_entries_on_customer_asset_id", using: :btree
    t.index ["source_type", "source_id"], name: "index_asset_entries_on_source_type_and_source_id", using: :btree
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                              null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",                        default: 0,              null: false
    t.integer  "children_count",               default: 0,              null: false
    t.boolean  "live",                         default: true,           null: false
    t.string   "name"
    t.text     "subtitle",       limit: 65535
    t.string   "slug",                                                  null: false
    t.string   "product_scope"
    t.boolean  "filtering",                    default: false,          null: false
    t.string   "view_mode",                    default: "product-grid", null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["depth"], name: "index_categories_on_depth", using: :btree
    t.index ["lft"], name: "index_categories_on_lft", using: :btree
    t.index ["parent_id"], name: "index_categories_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_categories_on_rgt", using: :btree
    t.index ["slug"], name: "index_categories_on_slug", using: :btree
    t.index ["store_id"], name: "index_categories_on_store_id", using: :btree
  end

  create_table "categories_departments", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "category_id",   null: false
    t.integer "department_id", null: false
    t.index ["category_id", "department_id"], name: "index_categories_departments_on_category_id_and_department_id", unique: true, using: :btree
  end

  create_table "categories_groups", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "category_id", null: false
    t.integer "group_id",    null: false
    t.index ["group_id"], name: "index_categories_groups_on_group_id", using: :btree
  end

  create_table "categories_products", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "category_id", null: false
    t.integer "product_id",  null: false
    t.index ["category_id", "product_id"], name: "index_categories_products_on_category_id_and_product_id", unique: true, using: :btree
  end

  create_table "columns", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "section_id",                                             null: false
    t.string   "alignment",                      default: "align-top",   null: false
    t.boolean  "pivot",                          default: false,         null: false
    t.string   "background_color",               default: "transparent", null: false
    t.text     "inline_styles",    limit: 65535
    t.integer  "priority",                       default: 0,             null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.index ["section_id"], name: "index_columns_on_section_id", using: :btree
  end

  create_table "component_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "product_id",               null: false
    t.integer  "component_id",             null: false
    t.integer  "quantity",     default: 1, null: false
    t.integer  "priority",     default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["product_id"], name: "index_component_entries_on_product_id", using: :btree
  end

  create_table "countries", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.string "code", limit: 2, null: false
    t.string "name"
    t.index ["code"], name: "index_countries_on_code", unique: true, using: :btree
  end

  create_table "customer_assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                null: false
    t.integer  "user_id",                 null: false
    t.integer  "product_id",              null: false
    t.integer  "amount",      default: 0, null: false
    t.integer  "value_cents", default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["product_id"], name: "index_customer_assets_on_product_id", using: :btree
    t.index ["store_id"], name: "index_customer_assets_on_store_id", using: :btree
    t.index ["user_id"], name: "index_customer_assets_on_user_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "priority",                 default: 0, null: false
    t.integer  "attempts",                 default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "departments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id"
    t.string   "name"
    t.string   "slug"
    t.integer  "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_departments_on_store_id", using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.integer  "priority",                default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                                       null: false
    t.string   "name",                                                           null: false
    t.boolean  "pricing_shown",                              default: true,      null: false
    t.boolean  "stock_shown",                                default: true,      null: false
    t.integer  "price_base",                                 default: 1,         null: false
    t.decimal  "price_modifier",     precision: 5, scale: 2, default: "0.0",     null: false
    t.boolean  "price_tax_included",                         default: true,      null: false
    t.integer  "premium_group_id"
    t.string   "premium_teaser"
    t.string   "appearance",                                 default: "default", null: false
    t.integer  "priority",                                   default: 0,         null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["store_id"], name: "index_groups_on_store_id", using: :btree
  end

  create_table "groups_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree
  end

  create_table "hostnames", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                       null: false
    t.integer  "parent_hostname_id"
    t.string   "fqdn",                           null: false
    t.integer  "priority",           default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["fqdn"], name: "index_hostnames_on_fqdn", using: :btree
    t.index ["parent_hostname_id"], name: "index_hostnames_on_parent_hostname_id", using: :btree
    t.index ["store_id"], name: "index_hostnames_on_store_id", using: :btree
  end

  create_table "iframes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "product_id"
    t.text     "html",       limit: 65535
    t.integer  "priority"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["product_id"], name: "index_iframes_on_product_id", using: :btree
  end

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id"
    t.string   "attachment_fingerprint"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "inventories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id"
    t.boolean  "fuzzy",          default: false, null: false
    t.string   "name"
    t.string   "inventory_code"
    t.integer  "priority",       default: 0,     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["store_id"], name: "index_inventories_on_store_id", using: :btree
  end

  create_table "inventory_check_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "inventory_check_id",             null: false
    t.integer  "inventory_item_id"
    t.integer  "product_id",                     null: false
    t.string   "lot_code"
    t.date     "expires_at"
    t.integer  "current",            default: 0, null: false
    t.integer  "difference"
    t.integer  "adjustment"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["inventory_check_id"], name: "index_inventory_check_items_on_inventory_check_id", using: :btree
    t.index ["inventory_item_id"], name: "index_inventory_check_items_on_inventory_item_id", using: :btree
    t.index ["product_id"], name: "index_inventory_check_items_on_product_id", using: :btree
  end

  create_table "inventory_checks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",     null: false
    t.integer  "inventory_id", null: false
    t.string   "note"
    t.datetime "completed_at"
    t.datetime "concluded_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["inventory_id"], name: "index_inventory_checks_on_inventory_id", using: :btree
    t.index ["store_id"], name: "index_inventory_checks_on_store_id", using: :btree
  end

  create_table "inventory_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "inventory_item_id", null: false
    t.date     "recorded_at"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "on_hand",           null: false
    t.integer  "reserved",          null: false
    t.integer  "pending",           null: false
    t.integer  "value_cents",       null: false
    t.string   "note"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["inventory_item_id"], name: "index_inventory_entries_on_inventory_item_id", using: :btree
    t.index ["recorded_at"], name: "index_inventory_entries_on_recorded_at", using: :btree
    t.index ["source_type", "source_id"], name: "index_inventory_entries_on_source_type_and_source_id", using: :btree
  end

  create_table "inventory_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "inventory_id", null: false
    t.integer  "product_id",   null: false
    t.string   "code",         null: false
    t.integer  "on_hand"
    t.integer  "reserved"
    t.integer  "pending"
    t.integer  "value_cents"
    t.date     "expires_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["inventory_id"], name: "index_inventory_items_on_inventory_id", using: :btree
    t.index ["product_id"], name: "index_inventory_items_on_product_id", using: :btree
  end

  create_table "linked_products_products", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "product_id",        null: false
    t.integer "linked_product_id", null: false
    t.index ["product_id", "linked_product_id"], name: "linked_products_by_product", unique: true, using: :btree
  end

  create_table "measurement_units", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "base_unit_id"
    t.integer  "exponent"
    t.string   "name",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["base_unit_id"], name: "index_measurement_units_on_base_unit_id", using: :btree
  end

  create_table "order_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "parent_item_id"
    t.integer  "order_id",                                                      null: false
    t.integer  "product_id",                                                    null: false
    t.string   "lot_code"
    t.string   "label"
    t.string   "additional_info"
    t.integer  "amount"
    t.integer  "shipped"
    t.integer  "price_cents"
    t.decimal  "tax_rate",              precision: 5, scale: 2, default: "0.0", null: false
    t.boolean  "price_includes_tax",                            default: false, null: false
    t.integer  "priority"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "product_code"
    t.string   "product_customer_code"
    t.string   "product_title"
    t.string   "product_subtitle"
    t.index ["order_id"], name: "index_order_items_on_order_id", using: :btree
    t.index ["parent_item_id"], name: "index_order_items_on_parent_item_id", using: :btree
    t.index ["product_id"], name: "index_order_items_on_product_id", using: :btree
  end

  create_table "order_report_rows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "order_type_id",                                                           null: false
    t.integer  "user_id"
    t.integer  "store_portal_id"
    t.string   "shipping_country_code", limit: 2
    t.integer  "product_id",                                                              null: false
    t.date     "ordered_at",                                                              null: false
    t.integer  "amount",                                                  default: 0,     null: false
    t.integer  "total_sans_tax_cents",                                    default: 0,     null: false
    t.integer  "total_tax_cents",                                         default: 0,     null: false
    t.integer  "total_with_tax_cents",                                    default: 0,     null: false
    t.decimal  "tax_rate",                        precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.index ["order_type_id"], name: "index_order_report_rows_on_order_type_id", using: :btree
    t.index ["ordered_at"], name: "index_order_report_rows_on_ordered_at", using: :btree
    t.index ["product_id"], name: "index_order_report_rows_on_product_id", using: :btree
    t.index ["shipping_country_code"], name: "index_order_report_rows_on_shipping_country_code", using: :btree
    t.index ["store_portal_id"], name: "index_order_report_rows_on_store_portal_id", using: :btree
    t.index ["user_id"], name: "index_order_report_rows_on_user_id", using: :btree
  end

  create_table "order_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id"
    t.integer  "source_id",                                      null: false
    t.integer  "destination_id",                                 null: false
    t.string   "name"
    t.string   "label"
    t.text     "instructions",     limit: 65535
    t.boolean  "has_shipping",                   default: false, null: false
    t.boolean  "has_installation",               default: false, null: false
    t.boolean  "has_payment",                    default: false, null: false
    t.string   "payment_gateway"
    t.boolean  "is_forwarded",                   default: false, null: false
    t.boolean  "prepaid_stock",                  default: false, null: false
    t.boolean  "is_exported",                    default: false, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["destination_id"], name: "index_order_types_on_destination_id", using: :btree
    t.index ["source_id"], name: "index_order_types_on_source_id", using: :btree
    t.index ["store_id"], name: "index_order_types_on_store_id", using: :btree
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                            null: false
    t.integer  "store_portal_id"
    t.integer  "order_items_count",                   default: 0,     null: false
    t.string   "number"
    t.string   "external_number"
    t.string   "vat_number"
    t.string   "your_reference"
    t.string   "our_reference"
    t.string   "message"
    t.integer  "user_id",                                             null: false
    t.integer  "customer_id",                                         null: false
    t.integer  "inventory_id"
    t.integer  "order_type_id"
    t.boolean  "includes_tax",                        default: true,  null: false
    t.datetime "completed_at"
    t.date     "shipping_at"
    t.date     "installation_at"
    t.date     "approved_at"
    t.date     "concluded_at"
    t.string   "customer_name"
    t.string   "customer_email"
    t.string   "customer_phone"
    t.string   "company_name"
    t.string   "contact_person"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.boolean  "has_billing_address",                 default: false, null: false
    t.string   "billing_address"
    t.string   "billing_postalcode"
    t.string   "billing_city"
    t.string   "billing_country_code",  limit: 2
    t.string   "shipping_address"
    t.string   "shipping_postalcode"
    t.string   "shipping_city"
    t.string   "shipping_country_code", limit: 2
    t.text     "notes",                 limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.datetime "cancelled_at"
    t.string   "store_name"
    t.string   "user_name"
    t.string   "user_email"
    t.string   "user_phone"
    t.string   "order_type_name"
    t.index ["customer_id"], name: "index_orders_on_customer_id", using: :btree
    t.index ["inventory_id"], name: "index_orders_on_inventory_id", using: :btree
    t.index ["order_type_id"], name: "index_orders_on_order_type_id", using: :btree
    t.index ["store_id"], name: "index_orders_on_store_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "orders_promotions", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "order_id",     null: false
    t.integer "promotion_id", null: false
    t.index ["order_id", "promotion_id"], name: "index_orders_promotions_on_order_id_and_promotion_id", unique: true, using: :btree
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                    null: false
    t.integer  "purpose",                      default: 1,    null: false
    t.string   "resource_type"
    t.integer  "resource_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",                        default: 0,    null: false
    t.integer  "children_count",               default: 0,    null: false
    t.boolean  "live",                         default: true, null: false
    t.string   "title"
    t.string   "slug",                                        null: false
    t.text     "metadata",       limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.index ["depth"], name: "index_pages_on_depth", using: :btree
    t.index ["lft"], name: "index_pages_on_lft", using: :btree
    t.index ["parent_id"], name: "index_pages_on_parent_id", using: :btree
    t.index ["rgt"], name: "index_pages_on_rgt", using: :btree
    t.index ["slug"], name: "index_pages_on_slug", using: :btree
    t.index ["store_id"], name: "index_pages_on_store_id", using: :btree
  end

  create_table "payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "order_id",     null: false
    t.string   "number"
    t.integer  "amount_cents", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["order_id"], name: "index_payments_on_order_id", using: :btree
  end

  create_table "pictures", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "image_id",                     null: false
    t.integer  "pictureable_id"
    t.string   "pictureable_type"
    t.integer  "purpose",                      null: false
    t.string   "variant"
    t.string   "caption"
    t.string   "url"
    t.integer  "priority",         default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["pictureable_type", "pictureable_id", "purpose", "priority"], name: "picture_master_index", using: :btree
  end

  create_table "policies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                    null: false
    t.string   "title"
    t.text     "content",        limit: 65535
    t.boolean  "mandatory",                    default: true, null: false
    t.datetime "accepted_at"
    t.integer  "accepted_by_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.index ["store_id"], name: "index_policies_on_store_id", using: :btree
  end

  create_table "product_properties", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "product_id",                           null: false
    t.integer  "property_id",                          null: false
    t.string   "value",                                null: false
    t.bigint   "value_i"
    t.decimal  "value_f",     precision: 10, scale: 2
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["product_id"], name: "index_product_properties_on_product_id", using: :btree
    t.index ["property_id"], name: "index_product_properties_on_property_id", using: :btree
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                              null: false
    t.integer  "vendor_id"
    t.integer  "purpose",                               default: 0,     null: false
    t.integer  "master_product_id"
    t.integer  "primary_variant_id"
    t.integer  "variants_count",                        default: 0,     null: false
    t.boolean  "live",                                  default: false, null: false
    t.string   "code"
    t.string   "customer_code"
    t.string   "title"
    t.string   "slug",                                                  null: false
    t.string   "subtitle"
    t.text     "description",             limit: 65535
    t.text     "overview",                limit: 65535
    t.text     "memo",                    limit: 65535
    t.integer  "mass"
    t.integer  "dimension_u"
    t.integer  "dimension_v"
    t.integer  "dimension_w"
    t.string   "lead_time"
    t.string   "additional_info_prompt"
    t.text     "shipping_notes",          limit: 65535
    t.integer  "cost_price_cents"
    t.date     "cost_price_modified_at"
    t.integer  "trade_price_cents"
    t.date     "trade_price_modified_at"
    t.integer  "retail_price_cents"
    t.integer  "tax_category_id",                                       null: false
    t.integer  "priority",                              default: 0,     null: false
    t.date     "available_at"
    t.date     "deleted_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["code"], name: "index_products_on_code", using: :btree
    t.index ["master_product_id"], name: "index_products_on_master_product_id", using: :btree
    t.index ["purpose"], name: "index_products_on_purpose", using: :btree
    t.index ["slug"], name: "index_products_on_slug", using: :btree
    t.index ["store_id"], name: "index_products_on_store_id", using: :btree
    t.index ["subtitle"], name: "index_products_on_subtitle", using: :btree
    t.index ["tax_category_id"], name: "index_products_on_tax_category_id", using: :btree
    t.index ["title"], name: "index_products_on_title", using: :btree
    t.index ["vendor_id"], name: "index_products_on_vendor_id", using: :btree
  end

  create_table "products_shipping_methods", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "product_id",         null: false
    t.integer "shipping_method_id", null: false
    t.index ["product_id"], name: "index_products_shipping_methods_on_product_id", using: :btree
  end

  create_table "products_tags", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "product_id", null: false
    t.integer "tag_id",     null: false
    t.index ["product_id", "tag_id"], name: "index_products_tags_on_product_id_and_tag_id", unique: true, using: :btree
  end

  create_table "products_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "product_id", null: false
    t.integer "user_id",    null: false
    t.index ["user_id", "product_id"], name: "index_products_users_on_user_id_and_product_id", unique: true, using: :btree
  end

  create_table "promoted_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "promotion_id",                                         null: false
    t.integer  "product_id",                                           null: false
    t.integer  "price_cents"
    t.decimal  "discount_percent", precision: 5, scale: 2
    t.integer  "amount_available"
    t.integer  "amount_sold",                              default: 0, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.index ["price_cents"], name: "index_promoted_items_on_price_cents", using: :btree
    t.index ["product_id"], name: "index_promoted_items_on_product_id", using: :btree
    t.index ["promotion_id"], name: "index_promoted_items_on_promotion_id", using: :btree
  end

  create_table "promotion_handlers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "promotion_id",        null: false
    t.string   "type",                null: false
    t.string   "description"
    t.integer  "default_price_cents"
    t.integer  "order_total_cents"
    t.integer  "required_items"
    t.integer  "items_total_cents"
    t.integer  "discount_percent"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["promotion_id"], name: "index_promotion_handlers_on_promotion_id", using: :btree
  end

  create_table "promotions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                               null: false
    t.integer  "group_id",                               null: false
    t.string   "promotion_handler_type",                 null: false
    t.boolean  "live",                   default: false, null: false
    t.string   "name"
    t.string   "slug",                                   null: false
    t.date     "first_date"
    t.date     "last_date"
    t.string   "activation_code"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["group_id"], name: "index_promotions_on_group_id", using: :btree
    t.index ["slug"], name: "index_promotions_on_slug", using: :btree
    t.index ["store_id"], name: "index_promotions_on_store_id", using: :btree
  end

  create_table "properties", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                            null: false
    t.integer  "value_type",                          null: false
    t.integer  "measurement_unit_id"
    t.boolean  "unit_pricing",        default: false, null: false
    t.boolean  "searchable",          default: false, null: false
    t.string   "name"
    t.string   "external_name"
    t.integer  "priority"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["measurement_unit_id"], name: "index_properties_on_measurement_unit_id", using: :btree
    t.index ["store_id"], name: "index_properties_on_store_id", using: :btree
  end

  create_table "requisite_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "product_id",               null: false
    t.integer "requisite_id",             null: false
    t.integer "priority",     default: 0, null: false
    t.index ["product_id"], name: "index_requisite_entries_on_product_id", using: :btree
    t.index ["requisite_id"], name: "index_requisite_entries_on_requisite_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "page_id",                                                  null: false
    t.string   "name"
    t.string   "width",                            default: "col-12",      null: false
    t.string   "layout",                           default: "twelve",      null: false
    t.boolean  "gutters",                          default: true,          null: false
    t.boolean  "swiper",                           default: false,         null: false
    t.boolean  "viewport",                         default: false,         null: false
    t.string   "shape"
    t.string   "background_color",                 default: "transparent", null: false
    t.string   "gradient_color",                   default: "#FFFFFF",     null: false
    t.string   "gradient_type"
    t.string   "gradient_direction"
    t.integer  "gradient_balance",                 default: 0,             null: false
    t.boolean  "fixed_background",                 default: false,         null: false
    t.text     "inline_styles",      limit: 65535
    t.integer  "priority",                         default: 0,             null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["page_id"], name: "index_sections_on_page_id", using: :btree
  end

  create_table "segments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "column_id",                                                    null: false
    t.integer  "resource_id"
    t.string   "resource_type"
    t.integer  "template",                          default: 0,                null: false
    t.string   "shape"
    t.string   "alignment",                         default: "align-top",      null: false
    t.string   "justification",                     default: "justify-center", null: false
    t.integer  "margin_top",                        default: 0,                null: false
    t.integer  "margin_bottom",                     default: 0,                null: false
    t.string   "inset",                             default: "inset-none",     null: false
    t.string   "foreground_color",                  default: "#333",           null: false
    t.string   "background_color",                  default: "transparent",    null: false
    t.text     "body",             limit: 16777215
    t.text     "metadata",         limit: 65535
    t.text     "content",          limit: 65535
    t.text     "inline_styles",    limit: 65535
    t.integer  "priority",                          default: 0,                null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.index ["column_id"], name: "index_segments_on_column_id", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_segments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "shipments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.string   "number"
    t.string   "tracking_code"
    t.string   "pickup_point_id"
    t.string   "package_type"
    t.integer  "mass"
    t.integer  "dimension_u"
    t.integer  "dimension_v"
    t.integer  "dimension_w"
    t.datetime "shipped_at"
    t.datetime "cancelled_at"
    t.text     "metadata",           limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["order_id"], name: "index_shipments_on_order_id", using: :btree
  end

  create_table "shipping_methods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                                               null: false
    t.string   "name",                                                   null: false
    t.string   "code"
    t.string   "shipping_gateway"
    t.boolean  "has_pickup_points",                      default: false, null: false
    t.boolean  "home_delivery",                          default: false, null: false
    t.integer  "delivery_time"
    t.date     "enabled_at"
    t.date     "disabled_at"
    t.text     "description",              limit: 65535
    t.integer  "shipping_cost_product_id"
    t.integer  "free_shipping_from_cents"
    t.integer  "detail_page_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.index ["store_id"], name: "index_shipping_methods_on_store_id", using: :btree
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "erp_number"
    t.string   "vat_number"
    t.boolean  "portal",                         default: false, null: false
    t.string   "name"
    t.string   "slug"
    t.integer  "default_group_id"
    t.string   "country_code",     limit: 2,                     null: false
    t.text     "settings",         limit: 65535
    t.string   "theme"
    t.integer  "footer_page_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "styles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                              null: false
    t.datetime "stylesheet_updated_at"
    t.integer  "stylesheet_file_size"
    t.string   "stylesheet_content_type"
    t.string   "stylesheet_file_name"
    t.text     "preamble",                limit: 65535
    t.text     "variables",               limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["store_id"], name: "index_styles_on_store_id", using: :btree
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",       null: false
    t.integer  "customer_id",    null: false
    t.string   "stripe_plan_id", null: false
    t.string   "stripe_id",      null: false
    t.date     "first_date"
    t.date     "last_date"
    t.integer  "status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id", using: :btree
    t.index ["store_id"], name: "index_subscriptions_on_store_id", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                       null: false
    t.string   "name"
    t.string   "appearance", default: "default", null: false
    t.boolean  "searchable", default: true,      null: false
    t.string   "slug",                           null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["slug"], name: "index_tags_on_slug", using: :btree
    t.index ["store_id"], name: "index_tags_on_store_id", using: :btree
  end

  create_table "tax_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id"
    t.string   "name"
    t.decimal  "rate",               precision: 5, scale: 2
    t.boolean  "included_in_retail",                         default: true, null: false
    t.integer  "priority",                                   default: 0,    null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.index ["store_id"], name: "index_tax_categories_on_store_id", using: :btree
  end

  create_table "transfer_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "transfer_id",               null: false
    t.integer  "order_item_id"
    t.integer  "product_id",                null: false
    t.string   "lot_code"
    t.date     "expires_at"
    t.integer  "amount",        default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["order_item_id"], name: "index_transfer_items_on_order_item_id", using: :btree
    t.index ["product_id"], name: "index_transfer_items_on_product_id", using: :btree
    t.index ["transfer_id"], name: "index_transfer_items_on_transfer_id", using: :btree
  end

  create_table "transfers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer  "store_id",                       null: false
    t.integer  "shipment_id"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.boolean  "return",         default: false, null: false
    t.string   "note"
    t.datetime "completed_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["destination_id"], name: "index_transfers_on_destination_id", using: :btree
    t.index ["shipment_id"], name: "index_transfers_on_shipment_id", using: :btree
    t.index ["source_id"], name: "index_transfers_on_source_id", using: :btree
    t.index ["store_id"], name: "index_transfers_on_store_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.string   "name"
    t.string   "email",                            default: "", null: false
    t.string   "phone"
    t.string   "billing_address"
    t.string   "billing_postalcode"
    t.string   "billing_city"
    t.string   "billing_country_code",   limit: 2
    t.string   "shipping_address"
    t.string   "shipping_postalcode"
    t.string   "shipping_city"
    t.string   "shipping_country_code",  limit: 2
    t.string   "locale"
    t.string   "encrypted_password",               default: "", null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci" do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end

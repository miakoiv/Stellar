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

ActiveRecord::Schema.define(version: 20150728120633) do

  create_table "categories", force: :cascade do |t|
    t.integer  "store_id",           limit: 4,               null: false
    t.integer  "parent_category_id", limit: 4
    t.string   "name",               limit: 255
    t.integer  "priority",           limit: 4,   default: 0, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "categories", ["parent_category_id"], name: "index_categories_on_parent_category_id", using: :btree
  add_index "categories", ["store_id"], name: "index_categories_on_store_id", using: :btree

  create_table "image_types", force: :cascade do |t|
    t.integer  "purpose",    limit: 4,   default: 0,    null: false
    t.string   "name",       limit: 255
    t.boolean  "bitmap",     limit: 1,   default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id",            limit: 4
    t.string   "imageable_type",          limit: 255
    t.integer  "image_type_id",           limit: 4
    t.integer  "priority",                limit: 4,   default: 0, null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  add_index "images", ["image_type_id"], name: "index_images_on_image_type_id", using: :btree
  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer  "store_id",   limit: 4
    t.integer  "purpose",    limit: 4,   default: 0,     null: false
    t.boolean  "fuzzy",      limit: 1,   default: false, null: false
    t.string   "name",       limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "inventory_id", limit: 4,                           null: false
    t.string   "code",         limit: 255,                         null: false
    t.string   "shelf",        limit: 255
    t.integer  "amount",       limit: 4
    t.decimal  "value",                    precision: 8, scale: 2
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "inventory_items", ["code"], name: "index_inventory_items_on_code", using: :btree
  add_index "inventory_items", ["inventory_id"], name: "index_inventory_items_on_inventory_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",              limit: 4,                           null: false
    t.integer  "product_id",            limit: 4,                           null: false
    t.integer  "amount",                limit: 4
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "product_code",          limit: 255
    t.string   "product_customer_code", limit: 255
    t.string   "product_title",         limit: 255
    t.string   "product_subtitle",      limit: 255
    t.decimal  "product_sales_price",               precision: 8, scale: 2
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "order_types", force: :cascade do |t|
    t.integer  "inventory_id",          limit: 4,                null: false
    t.integer  "adjustment_multiplier", limit: 4,   default: -1, null: false
    t.string   "name",                  limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "store_id",                   limit: 4,     null: false
    t.integer  "user_id",                    limit: 4,     null: false
    t.integer  "order_type_id",              limit: 4
    t.datetime "ordered_at"
    t.date     "shipping_at"
    t.datetime "approved_at"
    t.string   "company_name",               limit: 255
    t.string   "contact_person",             limit: 255
    t.text     "billing_address",            limit: 65535
    t.text     "shipping_address",           limit: 65535
    t.text     "notes",                      limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "store_name",                 limit: 255
    t.string   "store_contact_person_name",  limit: 255
    t.string   "store_contact_person_email", limit: 255
    t.string   "user_name",                  limit: 255
    t.string   "user_email",                 limit: 255
    t.string   "order_type_name",            limit: 255
  end

  add_index "orders", ["order_type_id"], name: "index_orders_on_order_type_id", using: :btree
  add_index "orders", ["store_id"], name: "index_orders_on_store_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "store_id",       limit: 4,     null: false
    t.integer  "parent_page_id", limit: 4
    t.string   "title",          limit: 255
    t.text     "content",        limit: 65535
    t.integer  "priority",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "pages", ["parent_page_id"], name: "index_pages_on_parent_page_id", using: :btree
  add_index "pages", ["store_id"], name: "index_pages_on_store_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "store_id",                limit: 4,                                         null: false
    t.integer  "category_id",             limit: 4
    t.string   "code",                    limit: 255
    t.string   "customer_code",           limit: 255
    t.string   "title",                   limit: 255
    t.string   "subtitle",                limit: 255
    t.text     "description",             limit: 65535
    t.text     "memo",                    limit: 65535
    t.decimal  "cost",                                  precision: 8, scale: 2
    t.date     "cost_modified_at"
    t.decimal  "sales_price",                           precision: 8, scale: 2
    t.date     "sales_price_modified_at"
    t.integer  "priority",                limit: 4,                             default: 0, null: false
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["store_id"], name: "index_products_on_store_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "parent_code",  limit: 255, null: false
    t.string   "product_code", limit: 255, null: false
    t.integer  "quantity",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "relationships", ["parent_code"], name: "index_relationships_on_parent_code", using: :btree
  add_index "relationships", ["product_code"], name: "index_relationships_on_product_code", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "stores", force: :cascade do |t|
    t.integer  "contact_person_id", limit: 4,                   null: false
    t.integer  "erp_number",        limit: 4
    t.boolean  "local_inventory",   limit: 1,   default: false, null: false
    t.string   "inventory_code",    limit: 255
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "theme",             limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "store_id",            limit: 4,                null: false
    t.string   "name",                limit: 255,              null: false
    t.string   "email",               limit: 255, default: "", null: false
    t.string   "encrypted_password",  limit: 255, default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",  limit: 255
    t.string   "last_sign_in_ip",     limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["store_id"], name: "index_users_on_store_id", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end

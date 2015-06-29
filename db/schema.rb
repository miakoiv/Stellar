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

ActiveRecord::Schema.define(version: 20150623063746) do

  create_table "brands", force: :cascade do |t|
    t.integer  "erp_number", limit: 4,   null: false
    t.string   "name",       limit: 255
    t.string   "slug",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "brand_id",           limit: 4,   null: false
    t.integer  "parent_category_id", limit: 4
    t.string   "name",               limit: 255
    t.integer  "priority",           limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "categories", ["brand_id"], name: "index_categories_on_brand_id", using: :btree
  add_index "categories", ["parent_category_id"], name: "index_categories_on_parent_category_id", using: :btree

  create_table "image_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id",            limit: 4
    t.string   "imageable_type",          limit: 255
    t.integer  "image_type_id",           limit: 4
    t.integer  "priority",                limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  add_index "images", ["image_type_id"], name: "index_images_on_image_type_id", using: :btree
  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer  "brand_id",   limit: 4,   null: false
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "inventories", ["brand_id"], name: "index_inventories_on_brand_id", using: :btree

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "inventory_id", limit: 4, null: false
    t.integer  "product_id",   limit: 4, null: false
    t.integer  "amount",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "inventory_items", ["inventory_id"], name: "index_inventory_items_on_inventory_id", using: :btree
  add_index "inventory_items", ["product_id"], name: "index_inventory_items_on_product_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",   limit: 4, null: false
    t.integer  "product_id", limit: 4, null: false
    t.integer  "amount",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
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
    t.integer  "user_id",       limit: 4, null: false
    t.integer  "order_type_id", limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "orders", ["order_type_id"], name: "index_orders_on_order_type_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "brand_id",    limit: 4,     null: false
    t.integer  "category_id", limit: 4
    t.string   "code",        limit: 255
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.text     "memo",        limit: 65535
    t.integer  "priority",    limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "products", ["brand_id"], name: "index_products_on_brand_id", using: :btree
  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "brand_id",            limit: 4,                null: false
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

  add_index "users", ["brand_id"], name: "index_users_on_brand_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

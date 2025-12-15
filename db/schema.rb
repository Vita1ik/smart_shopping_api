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

ActiveRecord::Schema[7.2].define(version: 2025_12_15_131048) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "brands_searches", id: false, force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "brand_id", null: false
    t.index ["search_id", "brand_id"], name: "index_brands_searches_on_search_id_and_brand_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "categories_searches", id: false, force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "category_id", null: false
    t.index ["search_id", "category_id"], name: "index_categories_searches_on_search_id_and_category_id", unique: true
  end

  create_table "categories_sources", id: false, force: :cascade do |t|
    t.bigint "source_id", null: false
    t.bigint "category_id", null: false
    t.index ["source_id", "category_id"], name: "index_categories_sources_on_source_id_and_category_id", unique: true
  end

  create_table "colors", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "colors_searches", id: false, force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "color_id", null: false
    t.index ["search_id", "color_id"], name: "index_colors_searches_on_search_id_and_color_id", unique: true
  end

  create_table "searches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.jsonb "price_range"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "results"
    t.integer "price_min"
    t.integer "price_max"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "searches_sizes", id: false, force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "size_id", null: false
    t.index ["search_id", "size_id"], name: "index_searches_sizes_on_search_id_and_size_id", unique: true
  end

  create_table "searches_target_audiences", id: false, force: :cascade do |t|
    t.bigint "search_id", null: false
    t.bigint "target_audience_id", null: false
    t.index ["search_id", "target_audience_id"], name: "idx_searches_ta_unique", unique: true
    t.index ["search_id"], name: "index_searches_target_audiences_on_search_id"
    t.index ["target_audience_id"], name: "index_searches_target_audiences_on_target_audience_id"
  end

  create_table "shoes", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "images", default: [], null: false
    t.bigint "price", null: false
    t.jsonb "prev_prices"
    t.text "product_url", null: false
    t.bigint "brand_id"
    t.bigint "size_id"
    t.bigint "color_id"
    t.bigint "target_audience_id"
    t.bigint "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["brand_id"], name: "index_shoes_on_brand_id"
    t.index ["category_id"], name: "index_shoes_on_category_id"
    t.index ["color_id"], name: "index_shoes_on_color_id"
    t.index ["size_id"], name: "index_shoes_on_size_id"
    t.index ["source_id"], name: "index_shoes_on_source_id"
    t.index ["target_audience_id"], name: "index_shoes_on_target_audience_id"
  end

  create_table "sizes", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "integration_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "target_audiences", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "google_uid"
    t.string "avatar"
    t.bigint "size_id"
    t.bigint "target_audience_id"
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid"
    t.index ["size_id"], name: "index_users_on_size_id"
    t.index ["target_audience_id"], name: "index_users_on_target_audience_id"
  end

  create_table "users_shoes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shoe_id", null: false
    t.boolean "liked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shoe_id"], name: "index_users_shoes_on_shoe_id"
    t.index ["user_id", "shoe_id"], name: "index_users_shoes_on_user_id_and_shoe_id", unique: true
    t.index ["user_id"], name: "index_users_shoes_on_user_id"
  end

  add_foreign_key "searches", "users"
  add_foreign_key "searches_target_audiences", "searches"
  add_foreign_key "searches_target_audiences", "target_audiences"
  add_foreign_key "shoes", "brands"
  add_foreign_key "shoes", "categories"
  add_foreign_key "shoes", "colors"
  add_foreign_key "shoes", "sizes"
  add_foreign_key "shoes", "sources"
  add_foreign_key "shoes", "target_audiences"
  add_foreign_key "users", "sizes"
  add_foreign_key "users", "target_audiences"
  add_foreign_key "users_shoes", "shoes"
  add_foreign_key "users_shoes", "users"
end

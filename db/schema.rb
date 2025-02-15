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

ActiveRecord::Schema[8.0].define(version: 2025_02_15_140153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "member_id"
    t.string "city"
    t.string "district"
    t.string "office_address"
    t.string "phone_number"
    t.integer "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_addresses_on_member_id"
  end

  create_table "bill_co_sponsors", force: :cascade do |t|
    t.bigint "bill_id"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_co_sponsors_on_bill_id"
    t.index ["member_id"], name: "index_bill_co_sponsors_on_member_id"
  end

  create_table "bill_sponsors", force: :cascade do |t|
    t.bigint "bill_id"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_sponsors_on_bill_id"
    t.index ["member_id"], name: "index_bill_sponsors_on_member_id"
  end

  create_table "bills", force: :cascade do |t|
    t.integer "congress"
    t.string "number"
    t.string "origin_chamber"
    t.string "origin_chamber_code"
    t.text "constitutional_authority_statement_text"
    t.string "title"
    t.string "bill_type"
    t.datetime "update_date"
    t.datetime "update_date_including_text"
    t.date "introduced_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "latest_actions", force: :cascade do |t|
    t.bigint "bill_id"
    t.string "action_date"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_latest_actions_on_bill_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "bio_guide_id"
    t.string "birth_year"
    t.boolean "current_member"
    t.string "direct_order_name"
    t.integer "district"
    t.string "first_name"
    t.string "honorific_name"
    t.string "inverted_order_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "display_name"
    t.string "official_website_url"
    t.string "state"
    t.datetime "update_date"
    t.string "image_attribution"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "party_histories", force: :cascade do |t|
    t.bigint "member_id"
    t.string "party_abbreviation"
    t.string "party_name"
    t.integer "start_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_party_histories_on_member_id"
  end

  add_foreign_key "addresses", "members"
  add_foreign_key "bill_co_sponsors", "bills"
  add_foreign_key "bill_co_sponsors", "members"
  add_foreign_key "bill_sponsors", "bills"
  add_foreign_key "bill_sponsors", "members"
  add_foreign_key "latest_actions", "bills"
  add_foreign_key "party_histories", "members"
end

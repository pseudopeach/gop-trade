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

ActiveRecord::Schema.define(version: 20151118064522) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidates", force: :cascade do |t|
    t.string   "id_name"
    t.string   "name"
    t.datetime "dropped_out_at"
  end

  add_index "candidates", ["id_name"], name: "index_candidates_on_id_name", unique: true, using: :btree

  create_table "reserves", force: :cascade do |t|
    t.integer  "resource_id", null: false
    t.integer  "owner_id",    null: false
    t.integer  "qty",         null: false
    t.datetime "updated_at"
  end

  add_index "reserves", ["owner_id"], name: "index_reserves_on_owner_id", using: :btree
  add_index "reserves", ["resource_id", "owner_id"], name: "index_reserves_on_resource_id_and_owner_id", unique: true, using: :btree

  create_table "trade_offers", force: :cascade do |t|
    t.integer  "candidate_id",   null: false
    t.integer  "offerer_id",     null: false
    t.integer  "bid_price"
    t.integer  "ask_price"
    t.integer  "qty_available"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "qty_authorized"
  end

  add_index "trade_offers", ["candidate_id"], name: "index_trade_offers_on_candidate_id", using: :btree
  add_index "trade_offers", ["offerer_id"], name: "index_trade_offers_on_offerer_id", using: :btree

  create_table "trades", force: :cascade do |t|
    t.integer  "candidate_id", null: false
    t.integer  "buyer_id",     null: false
    t.integer  "seller_id",    null: false
    t.integer  "qty",          null: false
    t.integer  "price_cents",  null: false
    t.datetime "executed_at"
  end

  add_index "trades", ["buyer_id"], name: "index_trades_on_buyer_id", using: :btree
  add_index "trades", ["candidate_id"], name: "index_trades_on_candidate_id", using: :btree
  add_index "trades", ["seller_id"], name: "index_trades_on_seller_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "key"
  end

end

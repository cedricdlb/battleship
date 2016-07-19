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

ActiveRecord::Schema.define(version: 20160614044554) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "title"
    t.integer  "player_1_id"
    t.integer  "player_2_id"
    t.integer  "whose_move"
    t.integer  "move_counter"
    t.integer  "game_state"
    t.integer  "player_1_fleet_status"
    t.integer  "player_2_fleet_status"
    t.text     "player_1_fleet_coords"
    t.text     "player_2_fleet_coords"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "moves", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "move_number"
    t.string   "attack_coords"
    t.string   "ship_part_hit"
    t.boolean  "hit"
    t.boolean  "ship_sunk"
    t.boolean  "fleet_sunk"
    t.text     "message"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

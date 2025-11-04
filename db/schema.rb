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

ActiveRecord::Schema[7.1].define(version: 2025_11_04_025614) do
  create_table "comments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "post_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "dex_abilities", force: :cascade do |t|
    t.integer "pokeapi_id"
    t.string "name"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dex_abilities_on_name", unique: true
  end

  create_table "dex_items", force: :cascade do |t|
    t.integer "pokeapi_id"
    t.string "name"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dex_items_on_name", unique: true
  end

  create_table "dex_moves", force: :cascade do |t|
    t.integer "pokeapi_id"
    t.string "name"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dex_moves_on_name", unique: true
  end

  create_table "dex_species", force: :cascade do |t|
    t.integer "pokeapi_id"
    t.string "name"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dex_species_on_name", unique: true
  end

  create_table "formats", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legality_issues", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "team_slot_id", null: false
    t.string "field"
    t.string "code"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_legality_issues_on_team_id"
    t.index ["team_slot_id"], name: "index_legality_issues_on_team_slot_id"
  end

  create_table "move_slots", force: :cascade do |t|
    t.integer "team_slot_id", null: false
    t.integer "move_id"
    t.integer "index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_slot_id", "index"], name: "index_move_slots_on_team_slot_id_and_index", unique: true
    t.index ["team_slot_id"], name: "index_move_slots_on_team_slot_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title"
    t.text "body"
    t.integer "post_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "team_slots", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "position"
    t.string "nickname"
    t.integer "tera_type"
    t.integer "nature_id"
    t.integer "ability_id"
    t.integer "item_id"
    t.integer "species_id"
    t.integer "ev_hp"
    t.integer "ev_atk"
    t.integer "ev_def"
    t.integer "ev_spa"
    t.integer "ev_spd"
    t.integer "ev_spe"
    t.integer "iv_hp"
    t.integer "iv_atk"
    t.integer "iv_def"
    t.integer "iv_spa"
    t.integer "iv_spd"
    t.integer "iv_spe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "position"], name: "index_team_slots_on_team_id_and_position", unique: true
    t.index ["team_id"], name: "index_team_slots_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "format_id"
    t.string "name"
    t.integer "status"
    t.integer "visibility"
    t.text "notes"
    t.datetime "last_validated_at"
    t.integer "legality_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["format_id"], name: "index_teams_on_format_id"
    t.index ["user_id", "updated_at"], name: "index_teams_on_user_id_and_updated_at"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "legality_issues", "team_slots"
  add_foreign_key "legality_issues", "teams"
  add_foreign_key "move_slots", "team_slots"
  add_foreign_key "posts", "users"
  add_foreign_key "team_slots", "teams"
  add_foreign_key "teams", "formats"
  add_foreign_key "teams", "users"
  add_foreign_key "teams", "users"
end

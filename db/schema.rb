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

ActiveRecord::Schema[7.1].define(version: 2025_12_02_015308) do
  create_table "dex_learnsets", force: :cascade do |t|
    t.integer "dex_species_id", null: false
    t.integer "dex_move_id", null: false
    t.string "method", null: false
    t.integer "level"
    t.string "version_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dex_move_id"], name: "index_dex_learnsets_on_dex_move_id"
    t.index ["dex_species_id", "dex_move_id", "version_group", "method"], name: "index_dex_learnsets_on_species_move_version_method"
    t.index ["dex_species_id"], name: "index_dex_learnsets_on_dex_species_id"
  end

  create_table "dex_moves", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "LOWER(name)", name: "index_dex_moves_on_lower_name", unique: true
  end

 create_table "dex_species", force: :cascade do |t|
    t.string "name"
    t.integer "pokeapi_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_slots", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "slot_index", null: false
    t.string "species"
    t.string "item"
    t.string "ability"
    t.string "nature"
    t.string "tera_type"
    t.string "nickname"
    t.integer "ev_hp", default: 0, null: false
    t.integer "ev_atk", default: 0, null: false
    t.integer "ev_def", default: 0, null: false
    t.integer "ev_spa", default: 0, null: false
    t.integer "ev_spd", default: 0, null: false
    t.integer "ev_spe", default: 0, null: false
    t.integer "iv_hp", default: 31, null: false
    t.integer "iv_atk", default: 31, null: false
    t.integer "iv_def", default: 31, null: false
    t.integer "iv_spa", default: 31, null: false
    t.integer "iv_spd", default: 31, null: false
    t.integer "iv_spe", default: 31, null: false
    t.string "move_1"
    t.string "move_2"
    t.string "move_3"
    t.string "move_4"
    t.boolean "illegal", default: false, null: false
    t.string "illegality_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "move1"
    t.string "move2"
    t.string "move3"
    t.string "move4"
    t.text "illegal_reasons"
    t.index ["team_id", "slot_index"], name: "index_team_slots_on_team_id_and_slot_index", unique: true
    t.index ["team_id"], name: "index_team_slots_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id"
    t.integer "status", default: 0, null: false
    t.integer "visibility", default: 0, null: false
    t.boolean "legal", default: false, null: false
    t.datetime "last_saved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_teams_on_user_id"
  end
  
  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "post_type"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.string "role", default: "member", null: false
    t.boolean "active", default: true, null: false
    t.string "otp_secret"
    t.boolean "otp_enabled", default: false, null: false
    t.text "backup_code_digests"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "google_uid"
    t.text "google_token"
    t.text "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "dex_learnsets", "dex_moves"
  add_foreign_key "dex_learnsets", "dex_species", column: "dex_species_id"
  add_foreign_key "team_slots", "teams"
  add_foreign_key "teams", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "users"
end

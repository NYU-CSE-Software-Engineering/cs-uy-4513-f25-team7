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

ActiveRecord::Schema[7.1].define(version: 2025_12_09_215322) do
  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

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

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "favoritable_type", null: false
    t.integer "favoritable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable"
    t.index ["user_id", "favoritable_type", "favoritable_id"], name: "index_favorites_uniqueness", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "follower_id", null: false
    t.integer "followee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followee_id"], name: "index_follows_on_followee_id"
    t.index ["follower_id", "followee_id"], name: "index_follows_on_follower_id_and_followee_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.string "subject"
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id", "read_at"], name: "index_messages_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id", null: false
    t.string "event_type", null: false
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "post_type"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dex_species_id"
    t.index ["dex_species_id"], name: "index_posts_on_dex_species_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.integer "rating", null: false
    t.text "body"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "deleted_at"], name: "index_reviews_on_team_id_and_deleted_at"
    t.index ["team_id", "user_id"], name: "index_reviews_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_reviews_on_team_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
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
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.integer "reviews_count", default: 0
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret"
    t.boolean "otp_enabled"
    t.string "google_uid"
    t.string "google_token"
    t.string "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "dex_learnsets", "dex_moves"
  add_foreign_key "dex_learnsets", "dex_species", column: "dex_species_id"
  add_foreign_key "favorites", "users"
  add_foreign_key "follows", "users", column: "followee_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "posts", "dex_species", column: "dex_species_id"
  add_foreign_key "posts", "users"
  add_foreign_key "reviews", "teams"
  add_foreign_key "reviews", "users"
  add_foreign_key "team_slots", "teams"
  add_foreign_key "teams", "users"
end

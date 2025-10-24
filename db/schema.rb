# For BBD testing

ActiveRecord::Schema[7.1].define(version: 2025_10_23_180855) do
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

end

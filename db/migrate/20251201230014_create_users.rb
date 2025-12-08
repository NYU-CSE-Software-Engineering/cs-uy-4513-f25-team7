class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, if_not_exists:true do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name
      t.string :role, default: "member", null: false
      t.boolean :active, default: true, null: false
      t.string :otp_secret
      t.boolean :otp_enabled, default: false, null: false
      t.text :backup_code_digests
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.string :google_uid
      t.text :google_token
      t.text :google_refresh_token
      t.datetime :google_token_expires_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end

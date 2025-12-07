class AddIdentityAndTwoFactorFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Basic profile fields
    unless column_exists?(:users, :name)
      add_column :users, :name, :string
    end

    unless column_exists?(:users, :role)
      add_column :users, :role, :string, null: false, default: "member"
    end

    unless column_exists?(:users, :active)
      add_column :users, :active, :boolean, null: false, default: true
    end

    # Two-factor auth fields
    unless column_exists?(:users, :otp_secret)
      add_column :users, :otp_secret, :string
    end

    unless column_exists?(:users, :otp_enabled)
      add_column :users, :otp_enabled, :boolean, null: false, default: false
    end

    unless column_exists?(:users, :backup_code_digests)
      add_column :users, :backup_code_digests, :text
    end

    # Password reset
    unless column_exists?(:users, :reset_digest)
      add_column :users, :reset_digest, :string
    end

    unless column_exists?(:users, :reset_sent_at)
      add_column :users, :reset_sent_at, :datetime
    end

    # Google OAuth fields
    unless column_exists?(:users, :google_uid)
      add_column :users, :google_uid, :string
    end

    unless column_exists?(:users, :google_token)
      add_column :users, :google_token, :text
    end

    unless column_exists?(:users, :google_refresh_token)
      add_column :users, :google_refresh_token, :text
    end

    unless column_exists?(:users, :google_token_expires_at)
      add_column :users, :google_token_expires_at, :datetime
    end
  end
end

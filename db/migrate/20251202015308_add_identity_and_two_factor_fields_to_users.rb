class AddIdentityAndTwoFactorFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp_secret, :string unless column_exists?(:users, :otp_secret)
    add_column :users, :otp_enabled, :boolean,
               default: false, null: false unless column_exists?(:users, :otp_enabled)

    # Google OAuth fields
    add_column :users, :google_uid, :string unless column_exists?(:users, :google_uid)
    add_column :users, :google_token, :string unless column_exists?(:users, :google_token)
    add_column :users, :google_refresh_token, :string unless column_exists?(:users, :google_refresh_token)
    add_column :users, :google_token_expires_at, :datetime unless column_exists?(:users, :google_token_expires_at)

    # Optional lockout fields
    add_column :users, :failed_login_attempts, :integer,
               default: 0, null: false unless column_exists?(:users, :failed_login_attempts)
    add_column :users, :locked_until, :datetime unless column_exists?(:users, :locked_until)

    add_index :users, :google_uid, unique: true unless index_exists?(:users, :google_uid)
  end
end

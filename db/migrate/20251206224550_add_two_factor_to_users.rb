class AddTwoFactorToUsers < ActiveRecord::Migration[7.1]
  def change
    # These columns were already added in 20251202015308_add_identity_and_two_factor_fields_to_users
    # Only add if they don't exist
    unless column_exists?(:users, :otp_secret)
      add_column :users, :otp_secret, :string
    end
    unless column_exists?(:users, :otp_enabled)
      add_column :users, :otp_enabled, :boolean
    end
  end
end

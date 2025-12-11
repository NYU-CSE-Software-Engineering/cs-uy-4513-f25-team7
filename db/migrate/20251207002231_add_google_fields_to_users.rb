class AddGoogleFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # These columns were already added in 20251202015308_add_identity_and_two_factor_fields_to_users
    # Only add if they don't exist
    unless column_exists?(:users, :google_uid)
      add_column :users, :google_uid, :string
    end
    unless column_exists?(:users, :google_token)
      add_column :users, :google_token, :string
    end
    unless column_exists?(:users, :google_refresh_token)
      add_column :users, :google_refresh_token, :string
    end
    unless column_exists?(:users, :google_token_expires_at)
      add_column :users, :google_token_expires_at, :datetime
    end
  end
end

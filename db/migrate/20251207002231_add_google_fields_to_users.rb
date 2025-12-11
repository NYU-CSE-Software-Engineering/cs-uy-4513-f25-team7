class AddGoogleFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_uid, :string unless column_exists?(:users, :google_uid)
    add_column :users, :google_token, :string unless column_exists?(:users, :google_token)
    add_column :users, :google_refresh_token, :string unless column_exists?(:users, :google_refresh_token)
    add_column :users, :google_token_expires_at, :datetime unless column_exists?(:users, :google_token_expires_at)
  end
end

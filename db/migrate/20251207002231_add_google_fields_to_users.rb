class AddGoogleFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_uid, :string
    add_column :users, :google_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_token_expires_at, :datetime
  end
end

class SecureGoogleTokens < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:users, :google_token)
      change_column :users, :google_token, :text
    end

    if column_exists?(:users, :google_refresh_token)
      change_column :users, :google_refresh_token, :text
    end

    add_index :users, :google_uid, unique: true unless index_exists?(:users, :google_uid)
  end
end

class AddEmailAndPasswordDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    # Email used for login + uniqueness
    unless column_exists?(:users, :email)
      add_column :users, :email, :string, null: false
      add_index  :users, :email, unique: true
    end

    # Required by has_secure_password
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string, null: false
    end
  end
end

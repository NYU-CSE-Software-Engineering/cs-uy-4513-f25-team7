class AddUsernameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string unless column_exists?(:users, :username)
    add_index  :users, :username, unique: true unless index_exists?(:users, :username, unique: true)
  end
end

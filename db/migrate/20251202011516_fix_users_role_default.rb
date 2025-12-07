class FixUsersRoleDefault < ActiveRecord::Migration[7.1]
  def up
    # Backfill any existing NULL roles just in case
    execute "UPDATE users SET role = 'user' WHERE role IS NULL"

    change_column_default :users, :role, from: nil, to: "user"
    change_column_null :users, :role, false
  end

  def down
    change_column_null :users, :role, true
    change_column_default :users, :role, from: "user", to: nil
  end
end

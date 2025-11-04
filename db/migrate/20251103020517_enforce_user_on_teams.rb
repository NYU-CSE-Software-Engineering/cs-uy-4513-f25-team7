class EnforceUserOnTeams < ActiveRecord::Migration[7.1]
  def change
    # make sure no NULLs remain BEFORE this (step 1)
    change_column_null :teams, :user_id, false
    add_foreign_key :teams, :users
    add_index :teams, [:user_id, :updated_at]
  end
end

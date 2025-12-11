class AddStatusToTeams < ActiveRecord::Migration[7.1]
  def change
    return if column_exists?(:teams, :status)

    add_column :teams, :status, :integer, null: false, default: 0
  end
end

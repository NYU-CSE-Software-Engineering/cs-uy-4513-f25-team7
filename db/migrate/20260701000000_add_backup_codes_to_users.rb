class AddBackupCodesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :backup_code_digests, :text unless column_exists?(:users, :backup_code_digests)
  end
end

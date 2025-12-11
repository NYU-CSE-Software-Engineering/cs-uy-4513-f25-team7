class AddTwoFactorToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp_secret, :string unless column_exists?(:users, :otp_secret)
    add_column :users, :otp_enabled, :boolean unless column_exists?(:users, :otp_enabled)
  end
end

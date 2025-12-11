class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :value, null: false
      t.string :ip_address, null: false
      t.timestamps
    end

    add_index :votes, [:post_id, :ip_address], unique: true
  end
end


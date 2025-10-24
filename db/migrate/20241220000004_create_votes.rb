class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :value, null: false # 1 for upvote, -1 for downvote
      t.string :ip_address, null: false # Simple way to track votes without user system
      t.timestamps
    end
    
    add_index :votes, [:post_id, :ip_address], unique: true
    add_index :votes, :post_id
  end
end

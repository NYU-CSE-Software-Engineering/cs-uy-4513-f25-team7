class CreateFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :follows, if_not_exists:true do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followee, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :follows, [:follower_id, :followee_id], unique: true
  end
end

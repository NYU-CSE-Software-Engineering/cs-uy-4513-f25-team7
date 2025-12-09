class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.datetime :deleted_at

      t.timestamps
    end

    # Ensure one review per user per team
    add_index :reviews, [:team_id, :user_id], unique: true
    # For fetching visible reviews efficiently
    add_index :reviews, [:team_id, :deleted_at]
  end
end

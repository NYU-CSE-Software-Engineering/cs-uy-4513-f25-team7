class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :post_type
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    
    add_index :posts, :title
    add_index :posts, :created_at
  end
end

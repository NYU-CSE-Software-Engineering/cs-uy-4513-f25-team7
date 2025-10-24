class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.timestamps
    end
    
    add_index :posts, :title
    add_index :posts, :created_at
  end
end

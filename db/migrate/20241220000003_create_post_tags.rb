class CreatePostTags < ActiveRecord::Migration[7.1]
  def change
    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true, index: false
      t.references :tag, null: false, foreign_key: true, index: false
      t.timestamps
    end
    
    add_index :post_tags, [:post_id, :tag_id], unique: true
    add_index :post_tags, :post_id
    add_index :post_tags, :tag_id
  end
end

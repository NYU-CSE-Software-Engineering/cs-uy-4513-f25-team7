class CreateTagsPostTagsVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :tags, if_not_exists: true do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, "LOWER(name)", unique: true, name: "index_tags_on_lower_name" unless index_exists?(:tags, "LOWER(name)", name: "index_tags_on_lower_name")

    create_table :post_tags, if_not_exists: true do |t|
      t.references :post, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :post_tags, [:post_id, :tag_id], unique: true unless index_exists?(:post_tags, [:post_id, :tag_id], unique: true)

    create_table :votes, if_not_exists: true do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :value, null: false
      t.string :ip_address, null: false
      t.timestamps
    end
    add_index :votes, [:post_id, :ip_address], unique: true unless index_exists?(:votes, [:post_id, :ip_address], unique: true)
  end
end


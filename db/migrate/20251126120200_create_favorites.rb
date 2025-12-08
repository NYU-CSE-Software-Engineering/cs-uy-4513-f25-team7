class CreateFavorites < ActiveRecord::Migration[7.1]
  def change
    create_table :favorites, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.references :favoritable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :favorites, [:user_id, :favoritable_type, :favoritable_id], unique: true, name: "index_favorites_uniqueness"
  end
end

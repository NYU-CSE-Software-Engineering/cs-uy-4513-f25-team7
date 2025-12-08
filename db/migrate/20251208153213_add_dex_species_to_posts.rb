class AddDexSpeciesToPosts < ActiveRecord::Migration[7.1]
  def change
    add_reference :posts, :dex_species, null: true, foreign_key: true
  end
end

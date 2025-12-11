class AddDexSpeciesToPosts < ActiveRecord::Migration[7.1]
  def change
    # Adds posts.dex_species_id (integer) and an index
    add_reference :posts, :dex_species, null: true, foreign_key: true
  end
end

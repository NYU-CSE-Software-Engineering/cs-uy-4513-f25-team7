class CreateDexSpecies < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_species, if_not_exists:true do |t|
      t.string :name
      t.integer :pokeapi_id

      t.timestamps
    end
  end
end

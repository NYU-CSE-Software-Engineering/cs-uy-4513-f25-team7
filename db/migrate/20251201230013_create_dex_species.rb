class CreateDexSpecies < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_species do |t|
      t.string :name
      t.integer :pokeapi_id

      t.timestamps
    end
  end
end


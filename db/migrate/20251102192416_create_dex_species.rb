class CreateDexSpecies < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_species do |t|
      t.integer :pokeapi_id
      t.string :name
      t.json :json

      t.timestamps
    end
  end
end

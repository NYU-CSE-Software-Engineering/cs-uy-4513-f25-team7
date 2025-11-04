class CreateDexMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_moves do |t|
      t.integer :pokeapi_id
      t.string :name
      t.json :json

      t.timestamps
    end
  end
end

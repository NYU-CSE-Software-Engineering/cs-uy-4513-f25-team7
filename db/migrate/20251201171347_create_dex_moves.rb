class CreateDexMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_moves, if_not_exists:true do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :dex_moves, "LOWER(name)", unique: true, name: "index_dex_moves_on_lower_name"
  end
end

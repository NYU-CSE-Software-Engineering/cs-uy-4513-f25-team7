class AddUniqueIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :team_slots,   [:team_id, :position], unique: true
    add_index :move_slots,   [:team_slot_id, :index], unique: true

    add_index :dex_species,   :name, unique: true
    add_index :dex_moves,     :name, unique: true
    add_index :dex_items,     :name, unique: true
    add_index :dex_abilities, :name, unique: true
  end
end

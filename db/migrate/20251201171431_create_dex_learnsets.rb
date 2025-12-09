class CreateDexLearnsets < ActiveRecord::Migration[7.1]
  def change
    create_table :dex_learnsets, if_not_exists:true do |t|
      t.references :dex_species, null: false, foreign_key: true
      t.references :dex_move,    null: false, foreign_key: true

      t.string  :method,        null: false   # "level-up", "machine", "egg", "tutor", etc.
      t.integer :level                         # may be 0 for TM / tutor
      t.string  :version_group                 # e.g., "sword-shield", "scarlet-violet"

      t.timestamps
    end

    add_index :dex_learnsets,
              [:dex_species_id, :dex_move_id, :version_group, :method],
              name: "index_dex_learnsets_on_species_move_version_method"
  end
end

class CreateSpeciesFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :species_follows do |t|
      t.references :user,       null: false, foreign_key: true
      t.references :dex_species, null: false, foreign_key: true

      t.timestamps
    end

    add_index :species_follows, [:user_id, :dex_species_id], unique: true
  end
end

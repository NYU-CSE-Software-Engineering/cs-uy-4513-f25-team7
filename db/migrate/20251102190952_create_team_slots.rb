class CreateTeamSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :team_slots do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :position
      t.string :nickname
      t.integer :tera_type
      t.integer :nature_id
      t.integer :ability_id
      t.integer :item_id
      t.integer :species_id
      t.integer :ev_hp
      t.integer :ev_atk
      t.integer :ev_def
      t.integer :ev_spa
      t.integer :ev_spd
      t.integer :ev_spe
      t.integer :iv_hp
      t.integer :iv_atk
      t.integer :iv_def
      t.integer :iv_spa
      t.integer :iv_spd
      t.integer :iv_spe

      t.timestamps
    end
  end
end

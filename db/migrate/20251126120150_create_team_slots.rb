class CreateTeamSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :team_slots do |t|
      t.references :team, null: false, foreign_key: true
      t.integer :slot_index, null: false
      t.string :species
      t.string :item
      t.string :ability
      t.string :nature
      t.string :tera_type
      t.string :nickname
      t.integer :ev_hp, default: 0
      t.integer :ev_atk, default: 0
      t.integer :ev_def, default: 0
      t.integer :ev_spa, default: 0
      t.integer :ev_spd, default: 0
      t.integer :ev_spe, default: 0
      t.integer :iv_hp, default: 31
      t.integer :iv_atk, default: 31
      t.integer :iv_def, default: 31
      t.integer :iv_spa, default: 31
      t.integer :iv_spd, default: 31
      t.integer :iv_spe, default: 31
      t.string :move_1
      t.string :move_2
      t.string :move_3
      t.string :move_4
      t.boolean :illegal, default: false
      t.text :illegality_reason

      t.timestamps
    end

    add_index :team_slots, [:team_id, :slot_index], unique: true
  end
end


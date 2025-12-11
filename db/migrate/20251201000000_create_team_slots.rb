class CreateTeamSlots < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:team_slots)

    create_table :team_slots do |t|
      t.integer :team_id, null: false
      t.integer :slot_index, null: false

      t.string :species
      t.string :item
      t.string :ability
      t.string :nature
      t.string :tera_type
      t.string :nickname

      t.integer :ev_hp,  default: 0,  null: false
      t.integer :ev_atk, default: 0,  null: false
      t.integer :ev_def, default: 0,  null: false
      t.integer :ev_spa, default: 0,  null: false
      t.integer :ev_spd, default: 0,  null: false
      t.integer :ev_spe, default: 0,  null: false

      t.integer :iv_hp,  default: 31, null: false
      t.integer :iv_atk, default: 31, null: false
      t.integer :iv_def, default: 31, null: false
      t.integer :iv_spa, default: 31, null: false
      t.integer :iv_spd, default: 31, null: false
      t.integer :iv_spe, default: 31, null: false

      t.string :move_1
      t.string :move_2
      t.string :move_3
      t.string :move_4

      t.boolean :illegal, default: false, null: false
      t.string  :illegality_reason

      # Existing duplicate move columns in schema
      t.string :move1
      t.string :move2
      t.string :move3
      t.string :move4

      t.text :illegal_reasons

      t.timestamps
    end

    add_index :team_slots, [:team_id, :slot_index], unique: true
    add_index :team_slots, :team_id
  end
end

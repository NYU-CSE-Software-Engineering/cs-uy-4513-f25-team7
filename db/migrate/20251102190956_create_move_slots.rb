class CreateMoveSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :move_slots do |t|
      t.references :team_slot, null: false, foreign_key: true
      t.integer :move_id
      t.integer :index

      t.timestamps
    end
  end
end

class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.integer :user_id
      t.integer :status, default: 0, null: false
      t.integer :visibility, default: 0, null: false
      t.boolean :legal, default: false, null: false
      t.datetime :last_saved_at

      t.timestamps
    end
    
    add_index :teams, :user_id
  end
end

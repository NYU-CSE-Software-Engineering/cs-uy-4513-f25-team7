class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    # Only create the table if it doesn't already exist
    create_table :teams, if_not_exists: true do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :public, null: false, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

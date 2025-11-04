class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.references :user, null: false, foreign_key: true
      t.references :format, null: false, foreign_key: true
      t.string :name
      t.integer :status
      t.integer :visibility
      t.text :notes
      t.datetime :last_validated_at
      t.integer :legality_state

      t.timestamps
    end
  end
end

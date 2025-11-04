class CreateLegalityIssues < ActiveRecord::Migration[7.1]
  def change
    create_table :legality_issues do |t|
      t.references :team, null: false, foreign_key: true
      t.references :team_slot, null: false, foreign_key: true
      t.string :field
      t.string :code
      t.text :message

      t.timestamps
    end
  end
end

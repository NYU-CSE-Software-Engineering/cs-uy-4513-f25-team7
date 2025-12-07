class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :public, null: false, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

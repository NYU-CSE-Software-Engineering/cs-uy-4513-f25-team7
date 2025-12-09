class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :subject
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:recipient_id, :read_at]
  end
end

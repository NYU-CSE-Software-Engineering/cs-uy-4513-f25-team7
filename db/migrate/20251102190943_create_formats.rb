class CreateFormats < ActiveRecord::Migration[7.1]
  def change
    create_table :formats do |t|
      t.string :key
      t.string :name
      t.boolean :default

      t.timestamps
    end
  end
end

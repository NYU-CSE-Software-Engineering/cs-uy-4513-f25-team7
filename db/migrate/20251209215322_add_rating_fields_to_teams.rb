class AddRatingFieldsToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :teams, :reviews_count, :integer, default: 0
  end
end

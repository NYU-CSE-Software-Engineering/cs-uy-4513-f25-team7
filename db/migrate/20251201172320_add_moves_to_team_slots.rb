# db/migrate/20251201000000_add_moves_to_team_slots.rb
class AddMovesToTeamSlots < ActiveRecord::Migration[7.1]
  def change
    add_column :team_slots, :move1, :string
    add_column :team_slots, :move2, :string
    add_column :team_slots, :move3, :string
    add_column :team_slots, :move4, :string
  end
end

# db/migrate/XXXXXXXXXXXXXX_add_illegal_reasons_to_team_slots.rb
class AddIllegalReasonsToTeamSlots < ActiveRecord::Migration[7.1]
  def change
    add_column :team_slots, :illegal_reasons, :text
  end
end

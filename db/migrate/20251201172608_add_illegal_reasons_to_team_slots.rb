# db/migrate/XXXXXXXXXXXXXX_add_illegal_reasons_to_team_slots.rb
class AddIllegalReasonsToTeamSlots < ActiveRecord::Migration[7.1]
  def change
    add_column :team_slots, :illegal_reasons, :text unless column_exists?(:team_slots, :illegal_reasons)
  end
end

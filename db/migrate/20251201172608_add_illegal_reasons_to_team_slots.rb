# db/migrate/XXXXXXXXXXXXXX_add_illegal_reasons_to_team_slots.rb
class AddIllegalReasonsToTeamSlots < ActiveRecord::Migration[7.1]
  def change
    # Only add column if table exists (for test environments that don't have teams)
    if table_exists?(:team_slots)
      add_column :team_slots, :illegal_reasons, :text
    end
  end
end

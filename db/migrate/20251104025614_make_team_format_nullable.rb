class MakeTeamFormatNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :teams, :format_id, true
  end
end

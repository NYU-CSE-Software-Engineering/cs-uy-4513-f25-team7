class AddTeamEditorColumnsToTeams < ActiveRecord::Migration[7.1]
  def change
    # 1. Rename :title to :name so it matches the model/params/views
    rename_column :teams, :title, :name

    # 2. Add visibility enum backing column
    # default: 0 => :private_team
    add_column :teams, :visibility, :integer, null: false, default: 0 unless column_exists?(:teams, :visibility)

    # 3. Add legality + last_saved_at fields used in the model/controller
    add_column :teams, :legal, :boolean, null: false, default: true unless column_exists?(:teams, :legal)
    add_column :teams, :last_saved_at, :datetime unless column_exists?(:teams, :last_saved_at)

    # 4. Optionally migrate existing boolean :public into the enum
    reversible do |dir|
      dir.up do
        # public = true  -> public_team (1)
        # public = false -> private_team (0)
        execute <<~SQL.squish
          UPDATE teams
          SET visibility = CASE WHEN public THEN 1 ELSE 0 END;
        SQL
      end
    end

    # (You can later write another migration to remove :public if you want)
  end
end

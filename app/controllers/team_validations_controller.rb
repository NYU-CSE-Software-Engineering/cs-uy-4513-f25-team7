# app/controllers/team_validations_controller.rb
class TeamValidationsController < ApplicationController
  before_action :authenticate_user!
  def create
    team = current_user.teams.find(params[:id])
    issues = TeamLegalityService.validate!(team)
    if issues.empty?
      team.update!(legality_state: :valid, last_validated_at: Time.current)
      render json: { legality: "legal", issues: [] }
    else
      team.update!(legality_state: :invalid, last_validated_at: Time.current)
      render json: { legality: "illegal", issues: issues }, status: :unprocessable_entity
    end
  end
end

class TeamsController < ApplicationController
  before_action :set_team

  def show
    @favorite = current_user&.favorites&.find_by(favoritable: @team)
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end
end

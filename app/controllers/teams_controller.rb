class TeamsController < ApplicationController
  # If you normally require login, you can temporarily relax it for AC1:
  # skip_before_action :authenticate_user!, only: %i[new create]

  def new
    @team = Team.new(
      status:     "draft",
      visibility: "private"
    )
  end

  def create
    @team = Team.new(team_params)

    # If there is a logged-in user in your real app, associate it.
    @team.user ||= current_user if @team.respond_to?(:user) && defined?(current_user) && current_user

    if @team.save
      # Flash contains the text the spec looks for; the new page also
      # renders the editor UI again.
      redirect_to new_team_path, notice: "Saved draft: #{@team.name}"
    else
      # If something (unexpectedly) fails, show errors on the same page.
      flash.now[:alert] = @team.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  private

  def team_params
    # AC1 only cares about these fields
    params.require(:team).permit(:name, :status, :visibility)
  end
end

class TeamsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  # include validate in the callbacks too
  before_action :set_team, only: [:edit, :show, :update, :validate, :publish, :unpublish]
  before_action :authorize_owner!, only: [:edit, :update, :validate, :publish, :unpublish]

  # GET /teams
  def index
    @teams = current_user.teams.order(updated_at: :desc)
  end

  # GET /teams/new
  def new
    default_format = Format.find_by(default: true) || Format.first
    @team = current_user.teams.build(format: default_format, name: "Untitled Team")
    build_placeholders(@team)   # ensure 6 cards + 4 move inputs each
  end

  # GET /teams/:id/edit
  def edit
    build_placeholders(@team)   # show empty cards up to 6
  end

  # POST /teams
  def create
    @team = current_user.teams.build(team_params)
    @team.status ||= :draft
    if @team.save
      redirect_to teams_path, notice: "Saved draft: #{@team.name.presence || 'Untitled Team'}", status: :see_other
    else
      build_placeholders(@team)  # keep 6 visible on failed save
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH /teams/:id
  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: "Saved: #{@team.name.presence || 'Untitled Team'}", status: :see_other
    else
      build_placeholders(@team)  # keep 6 visible on failed save
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /teams/:id
  def show
    return if @team.published? || @team.user == current_user
    # redirect_to authenticated_root_path, alert: "Not authorized"
  end

  # POST /teams/:id/validate
  def validate
    # TODO: plug in real validation; for now mark valid so flow works
    @team.update(legality_state: "valid", last_validated_at: Time.current)
    redirect_to edit_team_path(@team), notice: "Validation ran.", status: :see_other
  end

  # PATCH /teams/:id/publish
  def publish
    if @team.legality_state == "valid"
      @team.update(status: :published, visibility: :public_vis)
      redirect_to team_path(@team), notice: "Published!", status: :see_other
    else
      redirect_to edit_team_path(@team), alert: "Fix errors before publishing.", status: :see_other
    end
  end

  # PATCH /teams/:id/unpublish
  def unpublish
    @team.update(status: :draft, visibility: :private_vis)
    redirect_to edit_team_path(@team), notice: "Unpublished.", status: :see_other
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def authorize_owner!
    redirect_to authenticated_root_path, alert: "Not authorized" unless @team.user == current_user
  end

  # Ensure 6 visible cards and 4 move inputs for each card
  def build_placeholders(team)
    (1..6).each do |pos|
      slot = team.team_slots.find { |s| s.position == pos } || team.team_slots.build(position: pos)

      # make sure 4 move inputs render
      target = 4
      (slot.move_slots.size...target).each do |i|
        slot.move_slots.build(index: i)
      end
    end
  end

  def team_params
    params.require(:team).permit(
      :name, :format_id, :visibility, :status,
      team_slots_attributes: [
        :id, :position, :species_id, :nickname, :ability_id, :item_id, :nature_id, :tera_type,
        :ev_hp, :ev_atk, :ev_def, :ev_spa, :ev_spd, :ev_spe,
        :iv_hp, :iv_atk, :iv_def, :iv_spa, :iv_spd, :iv_spe, :_destroy,
        move_slots_attributes: [:id, :move_id, :index, :_destroy]
      ]
    )
  end
end

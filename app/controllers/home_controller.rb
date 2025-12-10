class HomeController < ApplicationController
  def index
    @teams = current_user&.teams&.order(updated_at: :desc) || []
  end
end

# app/controllers/species_controller.rb
class SpeciesController < ApplicationController
  layout false

  def index
    query = params[:q].to_s.strip
    @species = query.present? ? [query] : []
  end

  def show
    @name = params[:name]
    @following = FollowsController.following_for(@name)
    @follower_count = FollowsController.count_for(@name)
  end
end

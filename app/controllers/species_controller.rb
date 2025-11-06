# app/controllers/species_controller.rb
class SpeciesController < ApplicationController
  layout false

  def index
    @species = []
  end

  def show
    @name = params[:name]
    @following = FollowsController.following_for(@name)
    @follower_count = FollowsController.count_for(@name)
  end
end

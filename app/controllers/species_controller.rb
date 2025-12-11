# app/controllers/species_controller.rb
class SpeciesController < ApplicationController

  def index
    query = params[:q].to_s.strip
    @species = query.present? ? [query] : []
  end

  def show
    @name = params[:name]

    # Try to find this species in our Dex (imported earlier via lookup)
    @dex_species = DexSpecies.find_by("LOWER(name) = ?", @name.downcase)

    # Optional: lazily import here too if not found (so direct links still work)
    if @dex_species.nil? && !Rails.env.test?
      @dex_species = Dex::PokeapiImporter.import_species(@name.downcase)
    end

    # Sprite URL based on PokeAPI's sprite repo (no extra API call needed)
    @sprite_url =
      if @dex_species&.pokeapi_id
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{@dex_species.pokeapi_id}.png"
      end

    @following = FollowsController.following_for(@name, user_id: current_user&.id)
    @follower_count = FollowsController.count_for(@name)

    # Load discussion posts for this species
    @posts = @dex_species ? Post.for_species(@dex_species.id).includes(:user, :comments).order(created_at: :desc) : []
    @new_post = Post.new(dex_species: @dex_species) if user_signed_in?
  end

  def create_post
    @name = params[:name]
    @dex_species = DexSpecies.find_by("LOWER(name) = ?", @name.downcase)

    if @dex_species.nil?
      redirect_to species_path(name: @name), alert: "Species not found"
      return
    end

    @post = Post.new(post_params)
    @post.user = current_user
    @post.dex_species = @dex_species

    if @post.save
      redirect_to species_path(name: @name), notice: "Discussion posted!"
    else
      # Reload data for the show page
      @sprite_url = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{@dex_species.pokeapi_id}.png" if @dex_species&.pokeapi_id
      @following = FollowsController.following_for(@name, user_id: current_user&.id)
      @follower_count = FollowsController.count_for(@name)
      @posts = Post.for_species(@dex_species.id).includes(:user, :comments).order(created_at: :desc)
      @new_post = @post
      render :show
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :post_type)
  end
end

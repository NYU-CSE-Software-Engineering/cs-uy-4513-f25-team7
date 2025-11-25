# app/controllers/species_controller.rb
class SpeciesController < ApplicationController
  layout false

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
        # Or, for nicer art:
        # "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/#{@dex_species.pokeapi_id}.png"
      end

    @following = FollowsController.following_for(@name)
    @follower_count = FollowsController.count_for(@name)
  end
end

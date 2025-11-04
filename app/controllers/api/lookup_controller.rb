# app/controllers/api/lookup_controller.rb
class Api::LookupController < ApplicationController
  before_action :authenticate_user!
  def species;   render json: DexLookup.autocomplete_species(params[:q]); end
  def moves;     render json: DexLookup.autocomplete_moves(params[:q]); end
  def items;     render json: DexLookup.autocomplete_items(params[:q]); end
  def abilities; render json: DexLookup.autocomplete_abilities(params[:q]); end
  def natures;   render json: DexLookup.natures; end
  def learnset
    render json: DexLookup.learnset(species_id: params[:species_id], format_key: params[:format] || "sv")
  end
end

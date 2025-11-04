# app/controllers/dex_autocomplete_controller.rb
class DexAutocompleteController < ApplicationController
  skip_before_action :authenticate_user!

  def species
    term = params[:term].downcase
    results = DexSpecies.where("LOWER(name) LIKE ?", "%#{term}%").limit(12)
    render json: results.pluck(:id, :name)
  end
end

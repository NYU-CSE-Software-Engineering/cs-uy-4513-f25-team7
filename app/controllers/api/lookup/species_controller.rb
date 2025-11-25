# app/controllers/api/lookup/species_controller.rb
module Api
  module Lookup
    class SpeciesController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        query = params[:q].to_s.strip
        return render json: [] if query.blank?

        # 1) Try existing DB records (supports partial + case-insensitive search)
        matches = DexSpecies.lookup_query(query).select(:id, :name, :pokeapi_id)

        # 2) If nothing found, lazily import this species from PokeAPI
        if matches.empty? && !Rails.env.test? && likely_exact_name?(query)
          imported = Dex::PokeapiImporter.import_species(query.downcase)

          if imported
            matches = DexSpecies.where(id: imported.id).select(:id, :name, :pokeapi_id)
          end
        end

        render json: matches
      end

      private

      # Very simple heuristics so we don't call PokeAPI on total garbage constantly
      def likely_exact_name?(query)
        query.length >= 3 && query.match?(/\A[a-zA-Z\-]+\z/)
      end
    end
  end
end

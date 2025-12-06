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

        # 3) Return JSON with sprite_url included
        render json: matches.map { |species|
          {
            id:         species.id,
            name:       species.name,
            pokeapi_id: species.pokeapi_id,
            sprite_url: sprite_url_for(species)
          }
        }
      end

      private

      # Very simple heuristics so we don't call PokeAPI on total garbage constantly
      def likely_exact_name?(query)
        query.length >= 3 && query.match?(/\A[a-zA-Z\-]+\z/)
      end

      # Use the same convention as your species show page:
      # if your show page uses a different URL helper, mirror it here.
      def sprite_url_for(species)
        return nil unless species.pokeapi_id.present?

        # Classic PokeAPI sprite CDN:
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{species.pokeapi_id}.png"
      end
    end
  end
end

# app/services/dex/pokeapi_importer.rb
require "net/http"
require "json"

module Dex
  class PokeapiImporter
    BASE_URL = "https://pokeapi.co/api/v2"

    # Public: import *all* Pokémon species (you can tune the limit)
    def self.import_all_species(limit: 1010)
      new.import_all_species(limit: limit)
    end

    # Public: import a single species by name or id
    def self.import_species(name_or_id)
      new.import_species(name_or_id)
    end

    def import_all_species(limit:)
      list = get_json("#{BASE_URL}/pokemon?limit=#{limit}&offset=0")

      list.fetch("results", []).each_with_index do |entry, i|
        name = entry["name"]
        puts "[#{i + 1}/#{list['results'].size}] Importing #{name}..."
        import_species(name)
      end
    end

    def import_species(name_or_id)
      data = get_json("#{BASE_URL}/pokemon/#{name_or_id}")

      # PokeAPI stores names in lowercase; you can choose how to display them
      name = data["name"].capitalize
      pokeapi_id = data["id"]

      DexSpecies.find_or_initialize_by(pokeapi_id: pokeapi_id).tap do |species|
        species.name = name
        species.save!
      end
    end

    private

    def get_json(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise "PokeAPI error (#{response.code}) for #{uri}"
      end

      JSON.parse(response.body)
    end
  end
end

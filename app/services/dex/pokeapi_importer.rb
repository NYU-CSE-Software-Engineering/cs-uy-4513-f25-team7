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

    # Imports:
    # - DexSpecies (name, pokeapi_id)
    # - DexMove rows (name)
    # - DexLearnset rows for that species (move + method/level/version_group)
    def import_species(name_or_id)
      data = get_json("#{BASE_URL}/pokemon/#{name_or_id}")

      # PokeAPI stores names in lowercase; you can choose how to display them
      name       = data["name"].capitalize
      pokeapi_id = data["id"]

      species = DexSpecies.find_or_initialize_by(pokeapi_id: pokeapi_id).tap do |s|
        s.name = name
        s.save!
      end

      import_learnset_for_species(species, data)
    end

    private

    def import_learnset_for_species(species, pokemon_data)
      # pokemon_data["moves"] is an array of:
      # {
      #   "move" => { "name" => "earthquake", "url" => "..." },
      #   "version_group_details" => [ { "level_learned_at" => 55, "move_learn_method" => { "name" => "level-up" }, "version_group" => { "name" => "diamond-pearl" } }, ... ]
      # }
      pokemon_data.fetch("moves", []).each do |move_entry|
        move_name = move_entry.dig("move", "name")
        next unless move_name

        human_name = move_name.tr("-", " ").split.map(&:capitalize).join(" ")
        dex_move   = DexMove.find_or_create_by!(name: human_name)

        move_entry.fetch("version_group_details", []).each do |vg|
          method_name    = vg.dig("move_learn_method", "name") || "unknown"
          version_group  = vg.dig("version_group", "name")
          level          = vg["level_learned_at"]

          DexLearnset.find_or_create_by!(
            dex_species:   species,
            dex_move:      dex_move,
            method:        method_name,
            version_group: version_group,
            level:         level
          )
        end
      end
    end

    def get_json(url)
      uri      = URI(url)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise "PokeAPI error (#{response.code}) for #{uri}"
      end

      JSON.parse(response.body)
    end
  end
end

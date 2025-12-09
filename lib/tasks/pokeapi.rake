# lib/tasks/pokeapi.rake
namespace :dex do
  desc "Import Pokémon species from PokeAPI into DexSpecies"
  task import_species: :environment do
    # You can change this to a smaller limit while testing.
    limit = (ENV["LIMIT"] || 151).to_i

    puts "Importing up to #{limit} Pokémon species from PokeAPI..."
    Dex::PokeapiImporter.import_all_species(limit: limit)
    puts "Done."
  end

  desc "Import a single Pokémon species from PokeAPI (name or id)"
  task :import_species_one, [:name_or_id] => :environment do |_t, args|
    name_or_id = args[:name_or_id] || ENV["SPECIES"]
    if name_or_id.blank?
      abort "Usage: rails dex:import_species_one[pelipper] or SPECIES=pelipper"
    end

    Dex::PokeapiImporter.import_species(name_or_id)
    puts "Imported #{name_or_id}"
  end
end

namespace :dex do
  desc "Import all species from PokeAPI"
  task import_species: :environment do
    require "net/http"
    require "json"

    puts "Fetching species list..."
    res = Net::HTTP.get(URI("https://pokeapi.co/api/v2/pokemon-species?limit=2000"))
    list = JSON.parse(res)["results"] # [{name:, url:}]

    list.each_with_index do |row, i|
      name = row["name"]
      poke_id = row["url"].split("/").last.to_i

      DexSpecies.find_or_create_by!(pokeapi_id: poke_id) do |sp|
        sp.name = name
        sp.json = {}
      end

      puts "#{i} imported: #{name}"
    end

    puts "done."
  end
end

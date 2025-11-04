# lib/tasks/pokeapi.rake
namespace :pokeapi do
  desc "Import species by name (comma-separated)"
  task import_species: :environment do
    client = Pokeapi::Client.new
    names = ENV.fetch("NAMES").split(",").map(&:strip)
    names.each do |name|
      data = client.get("pokemon/#{name.downcase}")
      DexSpecies.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
      puts "Imported species #{name}"
    end
  end

  desc "Import move/item/ability by name"
  task :import_move, [:name] => :environment do |_, args|
    client = Pokeapi::Client.new
    data = client.get("move/#{args[:name].downcase}")
    DexMove.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
    puts "Imported move #{data["name"]}"
  end

  task :import_item, [:name] => :environment do |_, args|
    client = Pokeapi::Client.new
    data = client.get("item/#{args[:name].downcase}")
    DexItem.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  end

  task :import_ability, [:name] => :environment do |_, args|
    client = Pokeapi::Client.new
    data = client.get("ability/#{args[:name].downcase}")
    DexAbility.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  end
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Only seed DexSpecies if the table exists
if ActiveRecord::Base.connection.table_exists?('dex_species')
  DexSpecies.find_or_create_by!(name: "Pelipper")  {|s| s.pokeapi_id = 279 }
  DexSpecies.find_or_create_by!(name: "Ludicolo")  {|s| s.pokeapi_id = 272 }
  DexSpecies.find_or_create_by!(name: "Garchomp")  {|s| s.pokeapi_id = 445 }
end

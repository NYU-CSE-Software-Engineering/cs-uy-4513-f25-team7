# app/services/pokeapi/client.rb
require "net/http"
class Pokeapi::Client
  BASE = URI("https://pokeapi.co/api/v2/")

  def get(path)
    uri = BASE + path
    res = Net::HTTP.get_response(uri)
    raise "PokeAPI error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end
end

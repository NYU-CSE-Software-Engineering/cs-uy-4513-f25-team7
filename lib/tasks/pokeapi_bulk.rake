# lib/tasks/pokeapi_bulk.rake
require "net/http"
require "json"
require "uri"

namespace :pokeapi do
  namespace :import_all do
    task :moves      => :environment do PokeapiBulkImporter.new.import_all("move")     end
    task :items      => :environment do PokeapiBulkImporter.new.import_all("item")     end
    task :abilities  => :environment do PokeapiBulkImporter.new.import_all("ability")  end
    task :species    => :environment do PokeapiBulkImporter.new.import_all("pokemon")  end
  end
end

class PokeapiBulkImporter
  BASE = "https://pokeapi.co/api/v2/".freeze

  def initialize
    @limit    = (ENV["LIMIT"]    || 0).to_i
    @offset   = (ENV["OFFSET"]   || 0).to_i
    @sleep_ms = (ENV["SLEEP_MS"] || 120).to_i
    @dry      = ENV["DRY"].present?
  end

  def import_all(kind)
    case kind
    when "move"     then each_list_row("#{BASE}move?limit=2000")       { |row, i| import_move(row, i) }
    when "item"     then each_list_row("#{BASE}item?limit=4000")       { |row, i| import_item(row, i) }
    when "ability"  then each_list_row("#{BASE}ability?limit=2000")    { |row, i| import_ability(row, i) }
    when "pokemon"  then each_list_row("#{BASE}pokemon?limit=2000")    { |row, i| import_species(row, i) }
    else puts "Unknown kind: #{kind}"
    end
    puts "Done importing #{kind}."
  end

  private

  def each_list_row(list_url)
    total_seen = 0
    page_url = list_url
    while page_url
      data = get_json(page_url)
      results = Array(data["results"])
      results.each do |row|
        total_seen += 1
        next if total_seen <= @offset
        break if @limit > 0 && (total_seen - @offset) > @limit
        yield row, total_seen
      end
      break if @limit > 0 && (total_seen - @offset) >= @limit
      page_url = data["next"]
    end
  end

  def import_move(row, i)
    name, url = row.values_at("name", "url")
    id = id_from_url(url)
    print_prefix("move", i, id, name)
    return puts "  (dry) would upsert DexMove #{name}" if @dry
    data = get_json("#{BASE}move/#{id}")
    DexMove.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  rescue => e
    warn "  !! move #{name} failed: #{e.message}"
  ensure
    throttle
  end

  def import_item(row, i)
    name, url = row.values_at("name", "url")
    id = id_from_url(url)
    print_prefix("item", i, id, name)
    return puts "  (dry) would upsert DexItem #{name}" if @dry
    data = get_json("#{BASE}item/#{id}")
    DexItem.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  rescue => e
    warn "  !! item #{name} failed: #{e.message}"
  ensure
    throttle
  end

  def import_ability(row, i)
    name, url = row.values_at("name", "url")
    id = id_from_url(url)
    print_prefix("ability", i, id, name)
    return puts "  (dry) would upsert DexAbility #{name}" if @dry
    data = get_json("#{BASE}ability/#{id}")
    DexAbility.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  rescue => e
    warn "  !! ability #{name} failed: #{e.message}"
  ensure
    throttle
  end

  def import_species(row, i)
    name, url = row.values_at("name", "url")
    id = id_from_url(url)
    print_prefix("pokemon", i, id, name)
    return puts "  (dry) would upsert DexSpecies #{name}" if @dry
    data = get_json("#{BASE}pokemon/#{id}")
    DexSpecies.upsert({ name: data["name"], pokeapi_id: data["id"], json: data }, unique_by: :name)
  rescue => e
    warn "  !! pokemon #{name} failed: #{e.message}"
  ensure
    throttle
  end

  def id_from_url(url) = url.to_s.split("/").reject(&:blank?).last.to_i

  def get_json(url_or_path)
    uri = URI(url_or_path)
    uri = URI.join(BASE, url_or_path.to_s) unless uri.host
    res = Net::HTTP.get_response(uri)
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  def throttle
    sleep(@sleep_ms / 1000.0) if @sleep_ms.positive?
  end

  def print_prefix(kind, i, id, name)
    puts "#{i.to_s.rjust(4)} #{kind.ljust(8)} ##{id}  #{name}"
  end
end

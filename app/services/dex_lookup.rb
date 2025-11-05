# app/services/dex_lookup.rb
class DexLookup
  # Cross-DB case-insensitive WHERE
  def self.ci_match(column, q)
    if ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
      ["#{column} ILIKE ?", "%#{q}%"]
    else
      ["LOWER(#{column}) LIKE ?", "%#{q.to_s.downcase}%"]  # SQLite etc.
    end
  end

  def self.autocomplete_species(q)
    return [] if q.blank?
    DexSpecies.where(*ci_match("name", q))
              .order(:name).limit(20)
              .pluck(:id, :name, :pokeapi_id)
              .map { |id, n, pid| { id: id, name: n, pokeapi_id: pid } }
  end

  def self.autocomplete_moves(q)
    return [] if q.blank?
    DexMove.where(*ci_match("name", q))
           .order(:name).limit(20)
           .pluck(:id, :name)
           .map { |id, n| { id: id, name: n } }
  end

  def self.autocomplete_items(q)
    return [] if q.blank?
    DexItem.where(*ci_match("name", q))
           .order(:name).limit(20)
           .pluck(:id, :name)
           .map { |id, n| { id: id, name: n } }
  end

  def self.autocomplete_abilities(q)
    return [] if q.blank?
    DexAbility.where(*ci_match("name", q))
              .order(:name).limit(20)
              .pluck(:id, :name)
              .map { |id, n| { id: id, name: n } }
  end

  NATURES = %w[
    Hardy Lonely Brave Adamant Naughty Bold Docile Relaxed
    Impish Lax Timid Hasty Serious Jolly Naive Modest Mild
    Quiet Bashful Calm Gentle Sassy Careful Quirky
  ]

  def self.natures
    NATURES.map { |n| { id: n, name: n } }
  end

  # Optional: basic learnset helper (works if DexSpecies.json stores PokeAPI payloads)
  def self.learnset(species_id:, format_key: "sv")
    species = DexSpecies.find_by(id: species_id)
    return [] unless species

    vg = (format_key == "sv" ? "scarlet-violet" : format_key)
    ids = Array(species.json["moves"]).flat_map do |m|
      (m["version_group_details"] || []).any? { |d| d.dig("version_group", "name") == vg } ?
        [m.dig("move", "url").to_s.split("/").last.to_i] : []
    end.uniq.compact

    DexMove.where(pokeapi_id: ids).pluck(:id, :name).map { |id, name| { id: id, name: name } }
  end
end

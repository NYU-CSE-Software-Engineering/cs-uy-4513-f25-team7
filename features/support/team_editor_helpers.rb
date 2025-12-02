# features/support/team_editor_helpers.rb

module TeamEditorHelpers
  STAT_KEYS = %w[HP Atk Def SpA SpD Spe].freeze

  # Find the container for a given Pokémon slot
  def find_slot(slot_number)
    # Use the Nth .team-slot in document order.
    # Slot 1 => first .team-slot, Slot 2 => second, etc.
    index = slot_number.to_i - 1
    slots = all("div.team-slot", minimum: slot_number.to_i)

    slots[index]
  end

  # Fill a field by its label text within a given scope (slot card, etc.)
  def set_field(label_text, value, scope:)
    within(scope) do
      fill_in(label_text, with: value)
    end
  end

  # Parse EV string like:
  # "252 HP / 0 Atk / 196 Def / 0 SpA / 60 SpD / 0 Spe"
  # into { "HP" => 252, "Atk" => 0, ... }
  def parse_evs(evs_string)
    result = {}
    tokens = evs_string.to_s.split("/").map(&:strip)

    tokens.each do |token|
      # e.g. "252 HP", "60 SpD"
      if token =~ /(\d+)\s*([A-Za-z]+)/ # capture number + stat token
        amount = Regexp.last_match(1).to_i
        raw    = Regexp.last_match(2)

        stat =
          case raw.downcase
          when "hp"  then "HP"
          when "atk" then "Atk"
          when "def" then "Def"
          when "spa", "spatk", "sp.atk" then "SpA"
          when "spd", "spdef", "sp.def" then "SpD"
          when "spe", "spd+" then "Spe"
          else raw
          end

        result[stat] = amount
      end
    end

    result
  end

  # Parse IV string like:
  # "31 / 0 / 31 / 31 / 31 / 31"
  # into { "HP" => 31, "Atk" => 0, ... } by order HP/Atk/Def/SpA/SpD/Spe
  def parse_ivs(ivs_string)
    nums = ivs_string.to_s.split("/").map { |s| s.strip.to_i }
    result = {}

    STAT_KEYS.each_with_index do |stat, idx|
      result[stat] = nums[idx] || 0
    end

    result
  end

  # Fill EV fields inside a slot card
  def fill_evs_in_slot(slot_el, evs_hash)
    within(slot_el) do
      fill_in "HP EVs",  with: evs_hash["HP"]  if evs_hash.key?("HP")
      fill_in "Atk EVs", with: evs_hash["Atk"] if evs_hash.key?("Atk")
      fill_in "Def EVs", with: evs_hash["Def"] if evs_hash.key?("Def")
      fill_in "SpA EVs", with: evs_hash["SpA"] if evs_hash.key?("SpA")
      fill_in "SpD EVs", with: evs_hash["SpD"] if evs_hash.key?("SpD")
      fill_in "Spe EVs", with: evs_hash["Spe"] if evs_hash.key?("Spe")
    end
  end

  # Fill IV fields inside a slot card
  def fill_ivs_in_slot(slot_el, ivs_hash)
    within(slot_el) do
      fill_in "HP IVs",  with: ivs_hash["HP"]  if ivs_hash.key?("HP")
      fill_in "Atk IVs", with: ivs_hash["Atk"] if ivs_hash.key?("Atk")
      fill_in "Def IVs", with: ivs_hash["Def"] if ivs_hash.key?("Def")
      fill_in "SpA IVs", with: ivs_hash["SpA"] if ivs_hash.key?("SpA")
      fill_in "SpD IVs", with: ivs_hash["SpD"] if ivs_hash.key?("SpD")
      fill_in "Spe IVs", with: ivs_hash["Spe"] if ivs_hash.key?("Spe")
    end
  end

  # Fill move inputs inside a slot card
  # "Moves" column passes an array like ["Hurricane", "Tailwind", ...]
  def fill_moves_in_slot(slot_el, moves)
    moves = Array(moves).compact

    within(slot_el) do
      %w[Move\ 1 Move\ 2 Move\ 3 Move\ 4].each_with_index do |label, idx|
        fill_in label, with: moves[idx] || ""
      end
    end
  end
end

World(TeamEditorHelpers)

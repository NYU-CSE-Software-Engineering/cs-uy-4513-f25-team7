# features/support/team_editor_helpers.rb
module TeamEditorHelpers
  # Find the DOM element for a given Pokémon slot.
  def find_slot(slot_number)
    # First try data-slot, then fallback to #slot-n
    find(%([data-slot="#{slot_number}"]), match: :first)
  rescue Capybara::ElementNotFound
    find("#slot-#{slot_number}")
  end

  # Generic helper for filling a field by label within a scope
  def set_field(label_text, value, scope: nil)
    within(scope || page) do
      fill_in label_text, with: value
    end
  end

  # Parse "252 HP / 0 Atk / 196 Def / 0 SpA / 60 SpD / 0 Spe"
  def parse_evs(evs_string)
    parse_stat_line(evs_string)
  end

  # Parse "31 / 0 / 31 / 31 / 31 / 31"
  def parse_ivs(ivs_string)
    values = ivs_string.split("/").map { |s| s.strip.split.first.to_i }
    keys   = %i[hp atk def spa spd spe]
    keys.zip(values).to_h
  end

  def parse_stat_line(line)
    parts = line.split("/").map(&:strip)
    keys  = %i[hp atk def spa spd spe]
    result = {}

    parts.each_with_index do |part, idx|
      num = part.split.first.to_i
      result[keys[idx]] = num
    end

    result
  end

  def fill_evs_in_slot(slot_el, evs_hash)
    within(slot_el) do
      fill_in "HP EVs",  with: evs_hash[:hp]  if evs_hash[:hp]
      fill_in "Atk EVs", with: evs_hash[:atk] if evs_hash[:atk]
      fill_in "Def EVs", with: evs_hash[:def] if evs_hash[:def]
      fill_in "SpA EVs", with: evs_hash[:spa] if evs_hash[:spa]
      fill_in "SpD EVs", with: evs_hash[:spd] if evs_hash[:spd]
      fill_in "Spe EVs", with: evs_hash[:spe] if evs_hash[:spe]
    end
  end

  def fill_ivs_in_slot(slot_el, ivs_hash)
    within(slot_el) do
      fill_in "HP IVs",  with: ivs_hash[:hp]  if ivs_hash[:hp]
      fill_in "Atk IVs", with: ivs_hash[:atk] if ivs_hash[:atk]
      fill_in "Def IVs", with: ivs_hash[:def] if ivs_hash[:def]
      fill_in "SpA IVs", with: ivs_hash[:spa] if ivs_hash[:spa]
      fill_in "SpD IVs", with: ivs_hash[:spd] if ivs_hash[:spd]
      fill_in "Spe IVs", with: ivs_hash[:spe] if ivs_hash[:spe]
    end
  end

  def fill_moves_in_slot(slot_el, moves)
    within(slot_el) do
      moves.each_with_index do |move, idx|
        fill_in "Move #{idx + 1}", with: move
      end
    end
  end
end

World(TeamEditorHelpers)

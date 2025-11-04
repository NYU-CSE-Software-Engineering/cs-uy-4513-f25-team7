# app/services/team_legality_service.rb
class TeamLegalityService
  # Returns an array of issue hashes [{level:, team_slot_id:, field:, code:, message:}, ...]
  def self.validate!(team)
    issues = []
    team.legality_issues.delete_all

    # team-level: max 6 enforced by model; add any future clauses here (species clause, item clause, etc.)

    team.team_slots.each do |slot|
      next unless slot.species_id.present?
      issues.concat validate_slot(team, slot)
    end

    issues.each do |h|
      team.legality_issues.create!(
        team: team,
        team_slot_id: h[:team_slot_id],
        field: h[:field], code: h[:code], message: h[:message]
      )
    end
    issues
  end

  def self.validate_slot(team, slot)
    v = []
    # Species presence
    species = DexSpecies.find_by(id: slot.species_id)
    return [{level: :error, team_slot_id: slot.id, field: "species_id", code: "missing_species", message: "Choose a species"}] unless species

    # Ability legality
    if slot.ability_id.present?
      ability = DexAbility.find_by(id: slot.ability_id)
      v << err(slot, "ability_id", "unknown_ability", "Unknown ability") unless ability
      # Optional: confirm species can have this ability (using species.json abilities list)
      unless species.json["abilities"].any? { |a| a.dig("ability","name") == ability&.name }
        v << err(slot, "ability_id", "illegal_ability", "Ability not available for this species")
      end
    end

    # Item legality (you can plug format bans here if you maintain a banlist per Format)
    if slot.item_id.present?
      item = DexItem.find_by(id: slot.item_id)
      v << err(slot, "item_id", "unknown_item", "Unknown item") unless item
    end

    # Nature legality: ensure name exists
    if slot.nature_id.present? && !DexLookup::NATURES.include?(slot.nature_id_before_type_cast.to_s)
      v << err(slot, "nature_id", "illegal_nature", "Unknown nature")
    end

    # Moves
    learnable_ids = DexLookup.learnset(species_id: species.id, format_key: team.format.key).map { _1[:id] }
    slot.move_slots.each do |ms|
      next unless ms.move_id.present?
      if !learnable_ids.include?(ms.move_id)
        v << err(slot, "move_id", "unlearnable_move", "Move cannot be learned")
      end
    end

    # EV/IV violations already on model; surface as legality issues too
    slot.errors.full_messages.each do |msg|
      v << err(slot, "evs", "ev_violation", msg) if msg.include?("EV")
      v << err(slot, "ivs", "iv_violation", msg) if msg.include?("IV")
    end

    v
  end

  def self.err(slot, field, code, message)
    { level: :error, team_slot_id: slot.id, field:, code:, message: }
  end
end

class TeamLegalityChecker
  def initialize(team)
    @team = team
  end

  def run
    any_illegal = false

    @team.team_slots.each do |slot|
      check_slot(slot)
      any_illegal ||= slot.illegal? if slot.respond_to?(:illegal?)
    end

    # If there are no illegal slots, the team is legal
    @team.legal = !any_illegal if @team.respond_to?(:legal=)
  end

  private

  def check_slot(slot)
    # reset per-slot flags if attributes exist
    slot.illegal = false if slot.respond_to?(:illegal=)
    slot.illegality_reason = nil if slot.respond_to?(:illegality_reason=)

    return if slot.species.blank?

    # Our only hard rule for now: Garchomp cannot learn Wish
    if slot.species.to_s.strip.casecmp("Garchomp").zero? &&
       moves_for(slot).any? { |m| m.casecmp("Wish").zero? }
      slot.illegal = true if slot.respond_to?(:illegal=)
      slot.illegality_reason = "Move cannot be learned" if slot.respond_to?(:illegality_reason=)
    end
  end

  def moves_for(slot)
    [
      slot.respond_to?(:move_1) ? slot.move_1 : nil,
      slot.respond_to?(:move_2) ? slot.move_2 : nil,
      slot.respond_to?(:move_3) ? slot.move_3 : nil,
      slot.respond_to?(:move_4) ? slot.move_4 : nil
    ].compact.reject(&:blank?)
  end
end

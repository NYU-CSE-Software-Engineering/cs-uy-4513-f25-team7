# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamLegalityChecker do
  def build_team_with_slot(attrs = {})
    Team.new(name: "Test Team").tap do |team|
      team.team_slots.build({ slot_index: 1, species: nil }.merge(attrs))
    end
  end

  it "clears previous illegal flags when a slot has no species" do
    team = build_team_with_slot(
      species: "",
      illegal: true,
      illegality_reason: "Old reason"
    )

    described_class.new(team).run

    slot = team.team_slots.first
    expect(slot).not_to be_illegal
    expect(slot.illegality_reason).to be_nil
    expect(team.legal).to be true
  end

  it "marks a team as legal when all slots are fine" do
    team = build_team_with_slot(
      species: "Pikachu",
      move_1: "Thunderbolt",
      illegal: true,
      illegality_reason: "Should be cleared"
    )

    described_class.new(team).run

    slot = team.team_slots.first
    expect(slot).not_to be_illegal
    expect(slot.illegality_reason).to be_nil
    expect(team.legal).to be true
  end

  it "marks Garchomp + Wish as illegal and flips team legality" do
    team = build_team_with_slot(
      species: "Garchomp",
      move_1: "Earthquake",
      move_2: "Wish"
    )

    described_class.new(team).run

    slot = team.team_slots.first
    expect(slot).to be_illegal
    expect(slot.illegality_reason).to eq("Move cannot be learned")
    expect(team.legal).to be false
  end
end


# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeamSlot, type: :model do
  describe "EV/IV helpers" do
    let(:slot) do
      described_class.new(
        slot_index: 1,
        ev_hp: 4, ev_atk: 8, ev_def: 12, ev_spa: 16, ev_spd: 20, ev_spe: 24,
        iv_hp: 31, iv_atk: 30, iv_def: 29, iv_spa: 28, iv_spd: 27, iv_spe: 26
      )
    end

    it "returns EV values keyed by stat" do
      expect(slot.evs_hash).to eq(
        "HP" => 4, "Atk" => 8, "Def" => 12, "SpA" => 16, "SpD" => 20, "Spe" => 24
      )
    end

    it "returns IV values keyed by stat" do
      expect(slot.ivs_hash).to eq(
        "HP" => 31, "Atk" => 30, "Def" => 29, "SpA" => 28, "SpD" => 27, "Spe" => 26
      )
    end
  end

  describe "#moves" do
    it "compacts blank and nil move entries and aliases moves_array" do
      slot = described_class.new(
        slot_index: 1,
        move_1: "Thunderbolt",
        move_2: "",
        move_3: nil,
        move_4: "Surf"
      )

      expect(slot.moves).to eq(%w[Thunderbolt Surf])
      expect(slot.moves_array).to eq(%w[Thunderbolt Surf])
    end
  end

  describe "illegal_reasons alias" do
    it "reads and writes to illegality_reason" do
      slot = described_class.new(slot_index: 1, illegality_reason: "Old reason")

      expect(slot.illegal_reasons).to eq("Old reason")

      slot.illegal_reasons = "New reason"
      expect(slot.illegality_reason).to eq("New reason")
    end
  end

  describe "#recompute_legality!" do
    it "applies illegal move feedback from the learnset checker" do
      slot = described_class.new(slot_index: 1, species: "Garchomp", move_1: "Wish")
      allow(Dex::LearnsetChecker).to receive(:illegal_moves_for_slot)
        .with(slot, version_groups: nil)
        .and_return(["Wish"])

      slot.recompute_legality!

      expect(slot).to be_illegal
      expect(slot.illegal_reasons).to eq("Wish cannot be learned")
    end

    it "clears flags and persists changes on a saved slot" do
      team = Team.create!(name: "Persisted Team")
      slot = team.team_slots.create!(
        slot_index: 1,
        species: "Garchomp",
        move_1: "Wish",
        illegal: true,
        illegality_reason: "Old"
      )

      allow(Dex::LearnsetChecker).to receive(:illegal_moves_for_slot)
        .with(slot, version_groups: nil)
        .and_return([])

      expect { slot.recompute_legality! }
        .to change { slot.reload.illegal }.from(true).to(false)

      expect(slot.illegal_reasons).to be_nil
    end
  end
end


# spec/models/team_spec.rb
require "rails_helper"

RSpec.describe Team, type: :model do
  describe "#mark_legality!" do
    def build_team(name: "Rain Balance")
      Team.new(name: name).tap do |team|
        # Slot 1 – Pelipper (matches your Cucumber scenario)
        team.team_slots.build(
          slot_index: 1,
          species:   "Pelipper",
          item:      "Damp Rock",
          ability:   "Drizzle",
          nature:    "Bold",
          tera_type: "Water",
          ev_hp: 252, ev_atk: 0,   ev_def: 196,
          ev_spa: 0,  ev_spd: 60,  ev_spe: 0,
          iv_hp: 31,  iv_atk: 0,   iv_def: 31,
          iv_spa: 31, iv_spd: 31,  iv_spe: 31,
          move_1: "Hurricane",
          move_2: "Tailwind",
          move_3: "Wide Guard",
          move_4: "Protect"
        )

        # Slot 2 – Ludicolo (matches your Cucumber scenario)
        team.team_slots.build(
          slot_index: 2,
          species:   "Ludicolo",
          item:      "Life Orb",
          ability:   "Swift Swim",
          nature:    "Modest",
          tera_type: "Water",
          ev_hp: 4,   ev_atk: 0,  ev_def: 0,
          ev_spa: 252, ev_spd: 0, ev_spe: 252,
          iv_hp: 31,  iv_atk: 0, iv_def: 31,
          iv_spa: 31, iv_spd: 31, iv_spe: 31,
          move_1: "Hydro Pump",
          move_2: "Giga Drain",
          move_3: "Ice Beam",
          move_4: "Protect"
        )

        # Dummy filler slots 3–6 – simple legal placeholders
        (3..6).each do |idx|
          team.team_slots.build(
            slot_index: idx,
            species:   "Pikachu",
            item:      "Focus Sash",
            ability:   "Static",
            nature:    "Timid",
            tera_type: "Electric",
            ev_hp: 0,  ev_atk: 0,   ev_def: 0,
            ev_spa: 252, ev_spd: 4, ev_spe: 252,
            iv_hp: 31, iv_atk: 0,  iv_def: 31,
            iv_spa: 31, iv_spd: 31, iv_spe: 31,
            move_1: "Thunderbolt",
            move_2: "Volt Switch",
            move_3: "Protect",
            move_4: "Fake Out"
          )
        end
      end
    end

    it "marks a fully legal team as legal and keeps slots legal" do
      team = build_team

      team.mark_legality!

      expect(team).to be_legal
      expect(team.team_slots).to all(satisfy { |slot| !slot.illegal? })
    end

    it "marks team illegal if a slot has an illegal move (Garchomp + Wish)" do
      team = Team.new(name: "Bad Chomp")

      team.team_slots.build(
        slot_index: 1,
        species:   "Garchomp",
        item:      "Choice Band",
        ability:   "Rough Skin",
        nature:    "Jolly",
        tera_type: "Ground",
        ev_hp: 0,   ev_atk: 252, ev_def: 4,
        ev_spa: 0,  ev_spd: 0,   ev_spe: 252,
        iv_hp: 31,  iv_atk: 31,  iv_def: 31,
        iv_spa: 31, iv_spd: 31,  iv_spe: 31,
        move_1: "Earthquake",
        move_2: "Dragon Claw",
        move_3: "Wish",      # <- illegal
        move_4: "Protect"
      )

      team.mark_legality!

      expect(team).not_to be_legal
      chomp = team.team_slots.first
      expect(chomp).to be_illegal

      # Optional detail check if your model exposes it
      if chomp.respond_to?(:illegal_reasons)
        expect(chomp.illegal_reasons.to_s).to include("Wish")
        expect(chomp.illegal_reasons.to_s.downcase)
          .to satisfy { |s| s.include?("cannot be learned") || s.include?("illegal") }
      end
    end

    it "clears previous illegal state when the issue is fixed (e.g., Wish -> Rock Slide)" do
      team = Team.new(name: "Fixable Chomp")

      slot = team.team_slots.build(
        slot_index: 1,
        species:   "Garchomp",
        item:      "Choice Band",
        ability:   "Rough Skin",
        nature:    "Jolly",
        tera_type: "Ground",
        ev_hp: 0,   ev_atk: 252, ev_def: 4,
        ev_spa: 0,  ev_spd: 0,   ev_spe: 252,
        iv_hp: 31,  iv_atk: 31,  iv_def: 31,
        iv_spa: 31, iv_spd: 31,  iv_spe: 31,
        move_1: "Earthquake",
        move_2: "Dragon Claw",
        move_3: "Wish",      # illegal first
        move_4: "Protect"
      )

      # First pass – illegal
      team.mark_legality!
      expect(team).not_to be_legal
      expect(slot).to be_illegal

      # “Fix” the move like the Cucumber step: Wish -> Rock Slide
      slot.move_3 = "Rock Slide"

      # Second pass – should now be legal
      team.mark_legality!
      expect(team).to be_legal
      expect(slot).not_to be_illegal

      # Optional detail check if present
      if slot.respond_to?(:illegal_reasons)
        expect(slot.illegal_reasons).to be_blank
      end
    end
  end

  describe "#visibility_label" do
    it "returns a human-friendly label for private teams" do
      team = Team.new(name: "Test", visibility: :private_team)
      expect(team.visibility_label).to eq("Private")
    end

    it "returns a human-friendly label for public teams" do
      team = Team.new(name: "Test", visibility: :public_team)
      expect(team.visibility_label).to eq("Public")
    end
  end
end

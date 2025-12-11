# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dex::PokeapiImporter do
  let(:list_payload) do
    {
      "results" => [
        { "name" => "pikachu" }
      ]
    }
  end

  let(:species_payload) do
    {
      "name" => "pikachu",
      "id" => 25,
      "moves" => [
        {
          "move" => { "name" => "thunder-punch" },
          "version_group_details" => [
            {
              "level_learned_at" => 5,
              "move_learn_method" => { "name" => "level-up" },
              "version_group" => { "name" => "red-blue" }
            }
          ]
        }
      ]
    }
  end

  describe ".import_species" do
    before do
      allow_any_instance_of(described_class).to receive(:get_json)
        .with("#{described_class::BASE_URL}/pokemon/pikachu")
        .and_return(species_payload)
    end

    it "creates species, moves, and learnsets from the PokeAPI payload" do
      expect {
        described_class.import_species("pikachu")
      }.to change(DexSpecies, :count).by(1)
       .and change(DexMove, :count).by(1)
       .and change(DexLearnset, :count).by(1)

      species = DexSpecies.last
      move    = DexMove.last
      learnset = DexLearnset.last

      expect(species.name).to eq("Pikachu")
      expect(species.pokeapi_id).to eq(25)
      expect(move.name).to eq("Thunder Punch")
      expect(learnset.method).to eq("level-up")
      expect(learnset.level).to eq(5)
      expect(learnset.version_group).to eq("red-blue")
    end

    it "updates an existing species and avoids duplicate learnsets" do
      described_class.import_species("pikachu")

      expect {
        described_class.import_species("pikachu")
      }.not_to change(DexLearnset, :count)
    end
  end

  describe ".import_all_species" do
    it "pulls the list and imports each entry" do
      importer = described_class.new
      allow(described_class).to receive(:new).and_return(importer)
      allow(importer).to receive(:puts) # quiet progress output

      expect(importer).to receive(:get_json)
        .with("#{described_class::BASE_URL}/pokemon?limit=1&offset=0")
        .and_return(list_payload)

      expect(importer).to receive(:get_json)
        .with("#{described_class::BASE_URL}/pokemon/pikachu")
        .and_return(species_payload)

      importer.import_all_species(limit: 1)

      expect(DexSpecies.find_by(name: "Pikachu")).to be_present
      expect(DexMove.find_by(name: "Thunder Punch")).to be_present
    end
  end
end


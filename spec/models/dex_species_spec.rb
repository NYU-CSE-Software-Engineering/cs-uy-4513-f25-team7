# spec/models/dex_species_spec.rb
require "rails_helper"

RSpec.describe DexSpecies, type: :model do
  describe ".lookup_query" do
    # 🔧 Ensure a clean slate so uniqueness validations don't collide with fixtures
    before { DexSpecies.delete_all }

    let!(:pelipper) { DexSpecies.create!(name: "Pelipper", pokeapi_id: 279) }
    let!(:ludicolo) { DexSpecies.create!(name: "Ludicolo", pokeapi_id: 272) }
    let!(:garchomp) { DexSpecies.create!(name: "Garchomp", pokeapi_id: 445) }

    def result_names(query)
      described_class.lookup_query(query).pluck(:name)
    end

    it "returns exact matches when query matches the full name" do
      expect(result_names("Pelipper")).to eq(["Pelipper"])
    end

    it "returns partial matches when query is a substring" do
      expect(result_names("gar")).to eq(["Garchomp"])
    end

    it "is case-insensitive" do
      expect(result_names("pELipPer")).to eq(["Pelipper"])
    end

    it "returns empty when no species match" do
      expect(result_names("asdfghjkl")).to be_empty
    end

    it "returns empty when query is blank or whitespace" do
      expect(result_names("")).to be_empty
      expect(result_names("   ")).to be_empty
      expect(result_names(nil)).to be_empty
    end
  end
end

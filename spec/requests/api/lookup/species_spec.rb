# spec/requests/api/lookup/species_spec.rb
require "rails_helper"

RSpec.describe "Pokémon species lookup API", type: :request do
  describe "GET /api/lookup/species" do
    let!(:pelipper)  { DexSpecies.create!(name: "Pelipper",  pokeapi_id: 279) }
    let!(:ludicolo)  { DexSpecies.create!(name: "Ludicolo",  pokeapi_id: 272) }
    let!(:garchomp)  { DexSpecies.create!(name: "Garchomp",  pokeapi_id: 445) }

    def names_from_response
      JSON.parse(response.body).map { |row| row["name"] }
    end

    context "when querying by full species name" do
      it "returns only the exact match" do
        get "/api/lookup/species", params: { q: "Pelipper" }

        expect(response).to have_http_status(:ok)
        expect(names_from_response).to eq(["Pelipper"])
        expect(names_from_response).not_to include("Ludicolo", "Garchomp")
      end
    end

    context "when querying by partial string" do
      it "returns matching suggestions (case-insensitive, partial)" do
        get "/api/lookup/species", params: { q: "gar" }

        expect(response).to have_http_status(:ok)
        expect(names_from_response).to include("Garchomp")
        expect(names_from_response).not_to include("Pelipper")
      end
    end

    context "when querying with different case" do
      it "ignores case and still finds the species" do
        get "/api/lookup/species", params: { q: "pELipPer" }

        expect(response).to have_http_status(:ok)
        expect(names_from_response).to eq(["Pelipper"])
      end
    end

    context "when querying with nonsense" do
      it "returns an empty list" do
        get "/api/lookup/species", params: { q: "asdfghjkl" }

        expect(response).to have_http_status(:ok)
        expect(names_from_response).to be_empty
      end
    end

    context "when query is blank" do
      it "returns an empty list (guard against empty q)" do
        get "/api/lookup/species", params: { q: "" }

        expect(response).to have_http_status(:ok)
        expect(names_from_response).to be_empty
      end
    end
  end
end

# frozen_string_literal: true

# These steps exercise the /api/lookup/species endpoint (or similar)
# and are intentionally named so they don't collide with team-editor steps.

Given("the Pokédex has species data:") do |table|
  # You can either:
  #  - rely on existing seed data and just sanity-check, OR
  #  - create minimal DexSpecies records here for isolation.
  #
  # Here we create them if missing.
  table.hashes.each do |row|
    name = row.fetch("name")
    DexSpecies.find_or_create_by!(name: name) do |s|
      s.pokeapi_id ||= 9999
      # add any required attributes for your schema here
    end
  end
end

When("I request a species lookup with query {string}") do |query|
  # Hit your JSON lookup endpoint.
  # Adjust the path to match your routes.
  visit "/api/lookup/species?q=#{CGI.escape(query)}"
  @species_lookup_response = JSON.parse(page.body)
end

Then("the species lookup JSON should include these species:") do |table|
  expected_names = table.hashes.map { |row| row.fetch("name") }

  names_from_response = extract_species_names_from_lookup(@species_lookup_response)

  expected_names.each do |name|
    expect(names_from_response).to include(name),
                                   "expected lookup response to include #{name.inspect}, but got #{names_from_response.inspect}"
  end
end

Then("the species lookup JSON should not include species {string}") do |name|
  names_from_response = extract_species_names_from_lookup(@species_lookup_response)

  expect(names_from_response).not_to include(name),
                                     "expected lookup response NOT to include #{name.inspect}, but got #{names_from_response.inspect}"
end

Then("the species lookup JSON should be empty") do
  names_from_response = extract_species_names_from_lookup(@species_lookup_response)
  expect(names_from_response).to be_empty,
                                 "expected lookup response to be empty, but got #{names_from_response.inspect}"
end

# -------------------------
# Helper for parsing JSON
# -------------------------

def extract_species_names_from_lookup(response)
  # Shape this to match your API.
  #
  # For example, if your endpoint returns:
  #   [{ "id": 1, "name": "Pelipper", "pokeapi_id": 279 }, ...]
  # this is correct as-is.
  #
  # If it nests under a key (e.g. { "results": [...] }),
  # change to: response["results"].map { |row| row["name"] }.
  case response
  when Array
    response.map { |row| row["name"] }
  when Hash
    (response["results"] || []).map { |row| row["name"] }
  else
    []
  end
end

# frozen_string_literal: true
# These steps use Capybara + Devise (Warden) helpers.
# Adjust SELECTORS here if your HTML differs.
SPECIES_PAGE_SELECTOR      = '[data-test="species-page"]'
FOLLOW_BUTTON_SELECTOR     = '[data-test="follow-button"]'
FOLLOWER_COUNT_SELECTOR    = '[data-test="follower-count"]'
HOME_FEED_SELECTOR         = '[data-test="home-feed"]'
HOME_FEED_POST_SELECTOR    = '.post .post-title'
FOLLOWING_BADGE_SELECTOR   = '[data-test="following-badge"]'

# ---- Test helpers ----
module FollowStepsHelpers
  def routes
    Rails.application.routes.url_helpers
  end

  def find_species_by_name!(name)
    DexSpecies.find_by!(name: name)
  end

  def ensure_user!
    @current_user ||= User.first || User.create!(
      email: "tester+#{SecureRandom.hex(4)}@example.com",
      password: "password123!", password_confirmation: "password123!"
    )
  end

  def follower_count_text
    find(FOLLOWER_COUNT_SELECTOR).text.strip
  end

  def integer_from_text(text)
    text.to_s.scan(/\d+/).first.to_i
  end

  # Create a post associated to a species. Adjust if you use a join model.
  def create_post!(title:, species: nil)
    # If your Post <-> DexSpecies association uses a join (e.g., Tagging),
    # replace with Post.create!(title: ..., species: [species]) etc.
    Post.create!(
      title: title,
      body: "Test body for #{title}",
      dex_species: species,      # change to association your app expects
      user: ensure_user!
    )
  end

  def login!(user)
    include Warden::Test::Helpers
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  def visit_species_page(species)
    # Update to your actual route helper, e.g., routes.dex_species_path(species)
    path = routes.dex_species_path(species) rescue "/dex_species/#{species.id}"
    visit path
    expect(page).to have_css(SPECIES_PAGE_SELECTOR)
  end
end

World(FollowStepsHelpers)

# ---- Given ----

Given("I am signed in") do
  user = ensure_user!
  login!(user)
end

Given("the following species exist:") do |table|
  table.hashes.each do |row|
    DexSpecies.find_or_create_by!(name: row.fetch("name")) do |s|
      s.pokeapi_id ||= rand(1..2000) # harmless default if column exists
    end
  end
end

Given("I already follow {string}") do |name|
  species = find_species_by_name!(name)
  Follow.find_or_create_by!(user: ensure_user!, dex_species: species)
end

Given("I already follow {string} and {string}") do |a, b|
  steps %Q{
    Given I already follow "#{a}"
    And I already follow "#{b}"
  }
end

Given("{string} has {int} followers") do |name, count|
  species = find_species_by_name!(name)
  # Create distinct users to follow this species
  existing = Follow.where(dex_species: species).count
  (count - existing).times do
    u = User.create!(email: "seed+#{SecureRandom.hex(4)}@example.com",
                     password: "password123!", password_confirmation: "password123!")
    Follow.create!(user: u, dex_species: species)
  end
end

Given("there are {int} recent posts tagged with any of {string}") do |n, names|
  species_list = names.split(",").map(&:strip).map { |n| find_species_by_name!(n) }
  n.times do |i|
    sp = species_list[i % species_list.size]
    create_post!(title: "Followed Post #{i + 1} (#{sp.name})", species: sp)
  end
end

Given("there are {int} recent posts without any followed species") do |n|
  n.times do |i|
    create_post!(title: "General Post #{i + 1}", species: nil)
  end
end

# ---- When ----

When("I am on the {string} species page") do |name|
  species = find_species_by_name!(name)
  visit_species_page(species)
end

When("I click the follow button") do
  @before_count_text = follower_count_text rescue nil
  find(FOLLOW_BUTTON_SELECTOR, text: /Follow/i).click
end

When("I click the unfollow button") do
  @before_count_text = follower_count_text rescue nil
  find(FOLLOW_BUTTON_SELECTOR, text: /Unfollow/i).click
end

When("I visit my home feed") do
  # Adjust to your route helper for the home feed/dashboard
  path = routes.root_path rescue "/"
  visit path
  expect(page).to have_css(HOME_FEED_SELECTOR)
end

When("I search for species {string}") do |name|
  # If you have a search UI, interact with it here. For now, just hit index.
  visit routes.dex_species_index_path rescue "/dex_species"
  expect(page).to have_content(name)
end

# ---- Then ----

Then("I should see the button change to {string}") do |text|
  expect(page).to have_css(FOLLOW_BUTTON_SELECTOR, text: text)
end

Then("I should see the follower count increase by {int}") do |delta|
  after = integer_from_text(follower_count_text)
  before = integer_from_text(@before_count_text)
  expect(after).to eq(before + delta)
end

Then("I should see the follower count decrease by {int}") do |delta|
  after = integer_from_text(follower_count_text)
  before = integer_from_text(@before_count_text)
  expect(after).to eq(before - delta)
end

Then("I should see a follower count of {int}") do |expected|
  expect(integer_from_text(follower_count_text)).to eq(expected)
end

Then("the first {int} posts in the feed should be from {string}") do |n, names|
  allowed = names.split(",").map(&:strip)
  titles = all("#{HOME_FEED_SELECTOR} #{HOME_FEED_POST_SELECTOR}", minimum: n).first(n).map(&:text)
  # We only assert they *contain* one of the followed species in title label
  titles.each do |t|
    # Loosen this if your UI uses badges instead of names in titles
    expect(allowed.any? { |sp| t.include?(sp) }).to be(true),
                                                    "Expected '#{t}' to be from one of #{allowed.inspect}"
  end
end

Then("I should see a {string} badge next to {string}") do |badge_text, species_name|
  container = find(:xpath, "//*[contains(., #{species_name.inspect})][ancestor-or-self::*[contains(@data-test,'species') or contains(@data-test,'row')]]", match: :first) rescue page
  within(container) do
    expect(page).to have_css(FOLLOWING_BADGE_SELECTOR, text: badge_text)
  end
end

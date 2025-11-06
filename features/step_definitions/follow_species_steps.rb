# frozen_string_literal: true

# ----------------------------
# Selectors your feature expects
# ----------------------------
SPECIES_PAGE_SELECTOR    = '[data-test="species-page"]'
FOLLOW_BUTTON_SELECTOR   = '[data-test="follow-button"]'
FOLLOWER_COUNT_SELECTOR  = '[data-test="follower-count"]'
HOME_FEED_SELECTOR       = '[data-test="home-feed"]'       # not used in Scenario 1
HOME_FEED_POST_SELECTOR  = '.post .post-title'             # not used in Scenario 1
FOLLOWING_BADGE_SELECTOR = '[data-test="following-badge"]' # not used in Scenario 1

# ----------------------------
# In-memory registry (no models)
# ----------------------------
module FakeSpeciesRegistry
  extend self
  def reset!; @species = []; end
  def add(name); (@species ||= []) << name unless (@species || []).include?(name); end
  def all; @species || []; end
  def include?(name); all.include?(name); end
end

# ----------------------------
# Helpers
# ----------------------------
module FollowStepsHelpers
  def routes
    Rails.application.routes.url_helpers
  end

  def find_species_by_name!(name)
    raise "Unknown species #{name.inspect}" unless FakeSpeciesRegistry.include?(name)
    name
  end

  def follower_count_text
    find(FOLLOWER_COUNT_SELECTOR).text.strip
  end

  def integer_from_text(text)
    text.to_s.scan(/\d+/).first.to_i
  end
end
World(FollowStepsHelpers)

# ----------------------------
# Givens (MODEL-FREE)
# ----------------------------
Given("I am signed in") do
  # Pure fake; we don't need Devise or a User model for Scenario 1.
  @current_user = :fake
end

Given("the following species exist:") do |table|
  FakeSpeciesRegistry.reset!
  table.hashes.each { |row| FakeSpeciesRegistry.add(row.fetch("name")) }
end

# ----------------------------
# Whens (only what Scenario 1 needs)
# ----------------------------
When("I am on the {string} species page") do |name|
  find_species_by_name!(name)
  visit routes.species_path(name: name)
  expect(page).to have_css(SPECIES_PAGE_SELECTOR)
end

When("I click the follow button") do
  @before_count_text = follower_count_text rescue nil
  find(FOLLOW_BUTTON_SELECTOR, text: /Follow/i).click
end

When("I click the unfollow button") do
  @before_count_text = follower_count_text rescue nil
  find(FOLLOW_BUTTON_SELECTOR, text: /Unfollow/i).click
end

# ----------------------------
# Thens (only what Scenario 1 needs)
# ----------------------------
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
  titles.each do |t|
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

Given("I already follow {string}") do |name|
  FakeSpeciesRegistry.add(name) unless FakeSpeciesRegistry.include?(name)
  # Seed the in-memory controller so the page renders "Unfollow" and a nonzero count.
  FollowsController.seed_follow(name, count: 1)
end

Given("I already follow {string} and {string}") do |a, b|
  steps %Q{
    Given I already follow "#{a}"
    And I already follow "#{b}"
  }
end

Given("there are {int} recent posts tagged with any of {string}") do |n, names|
  species_list = names.split(",").map(&:strip)
  FakePostStore.reset! if FakePostStore.all.empty?

  n.times do |i|
    sp = species_list[i % species_list.size]
    title = "Followed Post #{i + 1} (#{sp})"
    FakePostStore.add(title: title, species: sp)
  end
end

Given("there are {int} recent posts without any followed species") do |n|
  n.times do |i|
    title = "General Post #{i + 1}"
    FakePostStore.add(title: title, species: nil)
  end
end

When("I visit my home feed") do
  visit routes.feed_path
  expect(page).to have_css(HOME_FEED_SELECTOR)
end

Given("{string} has {int} followers") do |name, count|
  # Ensure this species exists in our in-memory registry
  FakeSpeciesRegistry.add(name) unless FakeSpeciesRegistry.include?(name)
  # Seed follower count only (don’t toggle following state)
  FollowsController.seed_followers(name, count)
end

When("I search for species {string}") do |name|
  visit routes.species_index_path(q: name)
  expect(page).to have_content(name)
end

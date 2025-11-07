# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Home feed prioritization", type: :system do
  before do
    driven_by(:rack_test) if respond_to?(:driven_by)
    FollowsController.reset!
    FakePostStore.reset!
  end

  it "shows followed-species posts at the top of the feed" do
    # Seed follows
    FollowsController.seed_follow("Pelipper",   count: 1)
    FollowsController.seed_follow("Iron Hands", count: 1)

    # Seed posts: 5 followed (rotating species), 10 general
    ["Pelipper", "Iron Hands"].cycle.take(5).each_with_index do |sp, i|
      FakePostStore.add(title: "Followed Post #{i + 1} (#{sp})", species: sp)
    end
    10.times { |i| FakePostStore.add(title: "General Post #{i + 1}") }

    visit feed_path
    expect(page).to have_css('[data-test="home-feed"]')

    # Grab first 5 post titles
    titles = page.all('[data-test="home-feed"] .post .post-title', minimum: 5).first(5).map(&:text)
    expect(titles.length).to eq(5)

    # Assert each of the first five contains either followed species name
    allowed = ["Pelipper", "Iron Hands"]
    titles.each do |t|
      expect(allowed.any? { |sp| t.include?(sp) }).to be(true), "Expected '#{t}' to include one of #{allowed.inspect}"
    end
  end
end

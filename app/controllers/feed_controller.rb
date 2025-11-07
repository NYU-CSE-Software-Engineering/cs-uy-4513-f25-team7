class FeedController < ApplicationController
  layout false  # avoid sprockets/layout asset writes during these tests

  def show
    @followed_names = FollowsController.followed_species
    posts = FakePostStore.all

    followed_posts, other_posts = posts.partition { |p| @followed_names.include?(p.species) }
    @ordered_posts = followed_posts + other_posts
  end
end

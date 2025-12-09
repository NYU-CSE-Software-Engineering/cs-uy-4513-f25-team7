class FeedController < ApplicationController

  def index
    @followed_names = FollowsController.followed_species
    posts = FakePostStore.all

    unless posts.any?
      friend_ids = current_user&.followees&.pluck(:id) || []
      friend_ids << current_user.id if current_user

      scope = if friend_ids.any?
                Post.where(user_id: friend_ids)
              else
                Post.none
              end

      posts = scope.includes(:user, :comments).order(created_at: :desc)
    end

    followed_posts, other_posts = posts.partition do |p|
      p.respond_to?(:species) && @followed_names.include?(p.species)
    end
    @ordered_posts = followed_posts + other_posts
  end
end

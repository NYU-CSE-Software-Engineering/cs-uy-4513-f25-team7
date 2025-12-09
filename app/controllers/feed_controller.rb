# app/controllers/feed_controller.rb
# v6 - shows both followed users' posts and followed species' posts
# (INCLUDES YOUR OWN POSTS IF THEY HAVE COMMENTS BY OTHERS -
# ORGANIZED BY LATEST POST/COMMENT ACTIVITY)
class FeedController < ApplicationController
  def index
    # Names of species the current user is following (from the in-memory FollowsController)
    @followed_names = FollowsController.followed_species

    # In Cucumber tests this store is populated and should be used as-is
    posts = FakePostStore.all

    unless posts.any?
      # ----- Real DB backed feed -----

      # Users you follow (do NOT include yourself here)
      friend_ids = current_user&.followees&.pluck(:id) || []

      # Base scope used for all queries
      base_scope = Post.includes(:user, :comments, :dex_species)

      # Posts by trainers you follow
      friend_post_ids =
        if friend_ids.any?
          base_scope.where(user_id: friend_ids).pluck(:id)
        else
          []
        end

      # Posts for species you follow (exclude your own posts here)
      species_post_ids = []
      if @followed_names.any?
        species_ids = DexSpecies
                        .where("LOWER(name) IN (?)", @followed_names.map(&:downcase))
                        .pluck(:id)

        if species_ids.any?
          species_scope = base_scope.where(dex_species_id: species_ids)
          species_scope = species_scope.where.not(user_id: current_user.id) if current_user
          species_post_ids = species_scope.pluck(:id)
        end
      end

      # Your own posts that have at least one comment written by someone else
      own_posts_with_other_comments_ids =
        if current_user
          Comment.where.not(user_id: current_user.id)
                 .joins(:post)
                 .where(posts: { user_id: current_user.id })
                 .distinct
                 .pluck(:post_id)
        else
          []
        end

      # Union IDs and remove duplicates
      combined_ids = (
        friend_post_ids +
        species_post_ids +
        own_posts_with_other_comments_ids
      ).uniq

      posts =
        if combined_ids.any?
          base_scope.where(id: combined_ids)
        else
          base_scope.none
        end
    end

    if posts.first.is_a?(Post)
      posts_array = posts.to_a

      # Sort by latest relevant activity (post vs comments)
      if current_user
        posts_array.sort_by! { |post| -activity_timestamp(post, current_user) }
      else
        posts_array.sort_by!(&:created_at).reverse!
      end

      @ordered_posts = posts_array
    else
      # FakePostStore path used by existing tests
      followed_posts, other_posts = posts.partition do |p|
        p.respond_to?(:species) && @followed_names.include?(p.species)
      end

      @ordered_posts = (followed_posts + other_posts).uniq
    end
  end

  private

  # Returns a numeric timestamp used for sorting.
  # For your own posts we only consider comments from other users.
  def activity_timestamp(post, current_user)
    if post.user_id == current_user.id
      other_times = post.comments.reject { |c| c.user_id == current_user.id }
                        .map(&:created_at)
      (other_times.max || post.created_at).to_f
    else
      comment_time = post.comments.map(&:created_at).max
      [post.created_at, comment_time].compact.max.to_f
    end
  end
end


# v5 - shows both followed users' posts and followed species' posts
# (INCLUDES YOUR OWN POSTS IF THEY HAVE COMMENTS BY OTHERS) ------------------------------
# # app/controllers/feed_controller.rb
# class FeedController < ApplicationController
#   def index
#     # Names of species the current user is following (from the in-memory FollowsController)
#     @followed_names = FollowsController.followed_species

#     # In Cucumber tests this store is populated and should be used as-is
#     posts = FakePostStore.all

#     unless posts.any?
#       # ----- Real DB-backed feed -----

#       # Users you follow (do NOT include yourself here)
#       friend_ids = current_user&.followees&.pluck(:id) || []

#       # Base scope used for all queries
#       base_scope = Post.includes(:user, :comments, :dex_species)

#       # Posts by trainers you follow
#       friend_post_ids =
#         if friend_ids.any?
#           base_scope.where(user_id: friend_ids).pluck(:id)
#         else
#           []
#         end

#       # Posts for species you follow (exclude your own posts here)
#       species_post_ids = []
#       if @followed_names.any?
#         species_ids = DexSpecies
#                         .where("LOWER(name) IN (?)", @followed_names.map(&:downcase))
#                         .pluck(:id)

#         if species_ids.any?
#           species_scope = base_scope.where(dex_species_id: species_ids)
#           species_scope = species_scope.where.not(user_id: current_user.id) if current_user
#           species_post_ids = species_scope.pluck(:id)
#         end
#       end

#       # Your own posts that have at least one comment written by someone else
#       own_posts_with_other_comments_ids =
#         if current_user
#           Comment.where.not(user_id: current_user.id)
#                  .joins(:post)
#                  .where(posts: { user_id: current_user.id })
#                  .distinct
#                  .pluck(:post_id)
#         else
#           []
#         end

#       # Union IDs and remove duplicates
#       combined_ids = (
#         friend_post_ids +
#         species_post_ids +
#         own_posts_with_other_comments_ids
#       ).uniq

#       posts =
#         if combined_ids.any?
#           base_scope.where(id: combined_ids).order(created_at: :desc)
#         else
#           base_scope.none
#         end
#     end

#     if posts.first.is_a?(Post)
#       # Already filtered and ordered in SQL
#       @ordered_posts = posts
#     else
#       # FakePostStore path used by existing tests
#       followed_posts, other_posts = posts.partition do |p|
#         p.respond_to?(:species) && @followed_names.include?(p.species)
#       end

#       # Preserve order and remove duplicates (e.g., if a test post would match twice)
#       @ordered_posts = (followed_posts + other_posts).uniq
#     end
#   end
# end

# v4 similar to v2
# # app/controllers/feed_controller.rb
# class FeedController < ApplicationController
#   def index
#     # Names of species the current user is following (from the in-memory FollowsController)
#     @followed_names = FollowsController.followed_species

#     # In Cucumber tests this store is populated and should be used as-is
#     posts = FakePostStore.all

#     unless posts.any?
#       # ----- Real DB-backed feed -----

#       # Users you follow (do NOT include yourself here)
#       friend_ids = current_user&.followees&.pluck(:id) || []

#       # Base scope used for all queries
#       base_scope = Post.includes(:user, :comments, :dex_species)

#       # Posts by trainers you follow
#       friend_post_ids =
#         if friend_ids.any?
#           base_scope.where(user_id: friend_ids).pluck(:id)
#         else
#           []
#         end

#       # Posts for species you follow
#       species_post_ids = []
#       if @followed_names.any?
#         species_ids = DexSpecies
#                         .where('LOWER(name) IN (?)', @followed_names.map(&:downcase))
#                         .pluck(:id)

#         if species_ids.any?
#           species_post_ids = base_scope.where(dex_species_id: species_ids).pluck(:id)
#         end
#       end

#       # Your own posts that have at least one comment
#       # written by *someone else*
#       own_posts_with_other_comments_ids =
#         if current_user
#           Comment.where.not(user_id: current_user.id)
#                  .joins(:post)
#                  .where(posts: { user_id: current_user.id })
#                  .distinct
#                  .pluck(:post_id)
#         else
#           []
#         end

#       # Union IDs and remove duplicates
#       combined_ids = (
#         friend_post_ids +
#         species_post_ids +
#         own_posts_with_other_comments_ids
#       ).uniq

#       posts =
#         if combined_ids.any?
#           base_scope.where(id: combined_ids)
#                     .order(created_at: :desc)
#         else
#           base_scope.none
#         end
#     end

#     if posts.first.is_a?(Post)
#       # Already filtered and ordered in SQL
#       @ordered_posts = posts
#     else
#       # FakePostStore path used by existing tests
#       followed_posts, other_posts = posts.partition do |p|
#         p.respond_to?(:species) && @followed_names.include?(p.species)
#       end

#       # Preserve order and remove duplicates (e.g., if a test post would match twice)
#       @ordered_posts = (followed_posts + other_posts).uniq
#     end
#   end
# end


# V3 - shows both followed users' posts and followed species' posts 
# (DOES NOT INCLUDE YOUR OWN POSTS - NOT GREAT IN THE CASE SOMEONE 
# WRITES A COMMENT ON YOUR POST AND YOU WANT TO HAVE IT POP UP IN YOUR 
# FEED) -------------------------------------------------------------------------------
# class FeedController < ApplicationController
#   def index
#     # Names of species the current user is following (from the in-memory FollowsController)
#     @followed_names = FollowsController.followed_species

#     # In Cucumber tests this store is populated and should be used as-is
#     posts = FakePostStore.all

#     unless posts.any?
#       # ----- Real DB-backed feed -----
#       # Only people you follow – do NOT include yourself
#       friend_ids = current_user&.followees&.pluck(:id) || []

#       # Base scope used for all queries
#       base_scope = Post.includes(:user, :comments, :dex_species)

#       # Posts by users you follow
#       friend_post_ids =
#         if friend_ids.any?
#           base_scope.where(user_id: friend_ids).pluck(:id)
#         else
#           []
#         end

#       # Posts for species you follow
#       species_post_ids = []
#       if @followed_names.any?
#         species_ids = DexSpecies
#                         .where('LOWER(name) IN (?)', @followed_names.map(&:downcase))
#                         .pluck(:id)

#         if species_ids.any?
#           species_post_ids = base_scope.where(dex_species_id: species_ids).pluck(:id)
#         end
#       end

#       # Union IDs and remove duplicates
#       combined_ids = (friend_post_ids + species_post_ids).uniq

#       posts =
#         if combined_ids.any?
#           # Build final feed query:
#           #  - posts that match either “followed user” OR “followed species”
#           #  - exclude my own posts
#           scope = base_scope.where(id: combined_ids)
#           scope = scope.where.not(user_id: current_user.id) if current_user
#           scope.order(created_at: :desc)
#         else
#           base_scope.none
#         end
#     end

#     if posts.first.is_a?(Post)
#       # Already filtered and ordered in SQL
#       @ordered_posts = posts
#     else
#       # FakePostStore path used by existing tests
#       followed_posts, other_posts = posts.partition do |p|
#         p.respond_to?(:species) && @followed_names.include?(p.species)
#       end

#       # Preserve order and remove duplicates (e.g., if a test post would match twice)
#       @ordered_posts = (followed_posts + other_posts).uniq
#     end
#   end
# end

# V2 - shows both followed users' posts and followed species' posts 
#(SHOWS YOUR OWN POSTS AS WELL - BAD) --------------------------------------------------------
# class FeedController < ApplicationController
#   def index
#     # Names of species the current user is following (from the in-memory FollowsController)
#     @followed_names = FollowsController.followed_species

#     # In Cucumber tests this store is populated and should be used as-is
#     posts = FakePostStore.all

#     unless posts.any?
#       # ----- Real DB-backed feed -----
#       friend_ids = current_user&.followees&.pluck(:id) || []
#       friend_ids << current_user.id if current_user

#       # Base scope used for all queries
#       base_scope = Post.includes(:user, :comments, :dex_species)

#       # Posts by users you follow (and yourself)
#       friend_post_ids =
#         if friend_ids.any?
#           base_scope.where(user_id: friend_ids).pluck(:id)
#         else
#           []
#         end

#       # Posts for species you follow
#       species_post_ids = []
#       if @followed_names.any?
#         species_ids = DexSpecies
#                         .where('LOWER(name) IN (?)', @followed_names.map(&:downcase))
#                         .pluck(:id)

#         if species_ids.any?
#           species_post_ids = base_scope.where(dex_species_id: species_ids).pluck(:id)
#         end
#       end

#       # Union IDs and remove duplicates
#       combined_ids = (friend_post_ids + species_post_ids).uniq

#       posts =
#         if combined_ids.any?
#           base_scope.where(id: combined_ids).order(created_at: :desc)
#         else
#           base_scope.none
#         end
#     end

#     if posts.first.is_a?(Post)
#       # Already filtered and ordered in SQL
#       @ordered_posts = posts
#     else
#       # FakePostStore path used by existing tests
#       followed_posts, other_posts = posts.partition do |p|
#         p.respond_to?(:species) && @followed_names.include?(p.species)
#       end

#       # Preserve order and remove duplicates (e.g., if a test post would match twice)
#       @ordered_posts = (followed_posts + other_posts).uniq
#     end
#   end
# end

# V 1 - Worked on alternative version below, kept for reference 
# (ONLY SHOWS FOLLOWED USERS POSTS)-----------------
# class FeedController < ApplicationController

#   def index
#     @followed_names = FollowsController.followed_species
#     posts = FakePostStore.all

#     unless posts.any?
#       friend_ids = current_user&.followees&.pluck(:id) || []
#       friend_ids << current_user.id if current_user

#       scope = if friend_ids.any?
#                 Post.where(user_id: friend_ids)
#               else
#                 Post.none
#               end

#       posts = scope.includes(:user, :comments).order(created_at: :desc)
#     end

#     followed_posts, other_posts = posts.partition do |p|
#       p.respond_to?(:species) && @followed_names.include?(p.species)
#     end
#     # Keep ordering while removing duplicates (e.g., friend + followed species).
#     @ordered_posts = (followed_posts + other_posts).uniq
#   end
# end


# V0 -Base version kept for reference --------------------------------
# class FeedController < ApplicationController
# layout false # avoid sprockets/layout asset writes during these tests

#   layout false  # avoid sprockets/layout asset writes during these tests

#   def show
#     @followed_names = FollowsController.followed_species
#     posts = FakePostStore.all

#     @ordered_posts = followed_posts + other_posts
#   end
# end

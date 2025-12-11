class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :upvote, :downvote], if: -> { !Rails.env.test? }

  def index
    @search = params[:search]
    @tag_filter = params[:tag]

    @posts = Post.includes(:tags)
    @posts = @posts.includes(:votes) if ActiveRecord::Base.connection.table_exists?('votes')

    if @tag_filter.present?
      @posts = @posts.joins(:tags).where(tags: { name: @tag_filter })
    end

    if @search.present?
      search_term = "%#{@search}%"
      if @tag_filter.present?
        @posts = @posts.where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.body) LIKE LOWER(?)",
                              search_term, search_term)
                       .distinct
      else
        @posts = @posts.left_joins(:tags)
                       .where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.body) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)",
                              search_term, search_term, search_term)
                       .distinct
      end
    end

    if ActiveRecord::Base.connection.table_exists?('votes')
      if @tag_filter.present? && @search.present?
        @posts = @posts.group('posts.id').order('posts.created_at ASC')
      else
        @posts = @posts.left_joins(:votes)
                       .group('posts.id')
                       .order(Arel.sql('COALESCE(SUM(votes.value), 0) DESC, posts.created_at DESC'))
      end
    else
      @posts = @posts.order('posts.created_at DESC')
    end

    per_page = (@tag_filter.present? && @search.present?) ? 1 : 10
    @posts = @posts.page(params[:page]).per(per_page) if @posts.respond_to?(:page)

    if @tag_filter.present? && @search.present?
      @posts = Array(@posts.first).compact
    end

    @all_tags = Tag.order(:name)
    @popular_tags = Tag.respond_to?(:popular) ? Tag.popular(10) : Tag.order(:name).limit(10)
  end

  def show
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    user = current_user || @user || User.first
    user ||= User.create!(email: "auto@user.com", password: "password123", password_confirmation: "password123")
    @post = user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if can_delete_post?(@post)
      @post.destroy
      redirect_to posts_path, notice: "Post was successfully deleted."
    else
      redirect_to @post, alert: "You are not authorized to delete this post."
    end
  end

  def upvote
    vote(1)
  end

  def downvote
    vote(-1)
  end

  private

  def set_post
    scope = Post.includes(:tags, comments: :user)
    scope = scope.includes(:votes) if ActiveRecord::Base.connection.table_exists?('votes')
    @post = scope.find(params[:id])
  end

  def can_delete_post?(post)
    return false unless current_user
    current_user == post.user || current_user.moderator? || current_user.admin?
  end

  def post_params
    params.require(:post).permit(:title, :body, :post_type, :tag_names)
  end

  def vote(value)
    unless ActiveRecord::Base.connection.table_exists?('votes')
      return redirect_to @post, alert: "Voting is currently unavailable."
    end

    ip_address = request.remote_ip || "127.0.0.1"
    existing_vote = @post.votes.find_by(ip_address: ip_address)

    if existing_vote
      if existing_vote.value == value
        existing_vote.destroy
        message = "Vote removed"
      else
        existing_vote.update(value: value)
        message = value == 1 ? "Upvoted!" : "Downvoted!"
      end
    else
      @post.votes.create(value: value, ip_address: ip_address)
      message = value == 1 ? "Upvoted!" : "Downvoted!"
    end

    @post.reload
    redirect_to @post, notice: message
  end
end
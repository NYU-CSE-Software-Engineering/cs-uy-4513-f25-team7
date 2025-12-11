class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
  
  def index
    @search = params[:search]
    @tag_filter = params[:tag]
    
    @posts = Post.includes(:tags)
    @posts = @posts.includes(:votes) if ActiveRecord::Base.connection.table_exists?('votes')
    
    # Filter by tag first (if present)
    if @tag_filter.present?
      @posts = @posts.joins(:tags).where(tags: { name: @tag_filter })
    end
    
    # Search includes tag names (works with or without tag filter)
    # Use LIKE for SQLite compatibility (ILIKE is PostgreSQL only)
    if @search.present?
      search_term = "%#{@search}%"
      if @tag_filter.present?
        # Already joined tags, so we can use tags.name directly
        @posts = @posts.where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.content) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)", 
                             search_term, search_term, search_term)
      else
        # Need to join tags for search
        @posts = @posts.left_joins(:tags)
                      .where("LOWER(posts.title) LIKE LOWER(?) OR LOWER(posts.content) LIKE LOWER(?) OR LOWER(tags.name) LIKE LOWER(?)", 
                             search_term, search_term, search_term)
                      .distinct
      end
    end
    
    # Order by vote score, then by creation date
    if ActiveRecord::Base.connection.table_exists?('votes')
      @posts = @posts.left_joins(:votes)
                     .group('posts.id')
                     .order(Arel.sql('COALESCE(SUM(votes.value), 0) DESC, posts.created_at DESC'))
    else
      @posts = @posts.order('posts.created_at DESC')
    end
    
    @posts = @posts.page(params[:page]).per(10)
    
    @all_tags = Tag.order(:name)
    @popular_tags = Tag.popular(10)
  end
  
  def show
    @post = Post.includes(:tags)
    @post = @post.includes(:votes) if ActiveRecord::Base.connection.table_exists?('votes')
    @post = @post.find(params[:id])
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully deleted.'
  end
  
  def upvote
    vote(1)
  end
  
  def downvote
    vote(-1)
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :tag_names)
  end
  
  def vote(value)
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
    
    respond_to do |format|
      format.html { redirect_to @post, notice: message }
      format.json { 
        render json: { 
          success: true, 
          message: message,
          vote_score: @post.vote_score,
          user_vote: @post.votes.find_by(ip_address: ip_address)&.value
        } 
      }
    end
  end
end

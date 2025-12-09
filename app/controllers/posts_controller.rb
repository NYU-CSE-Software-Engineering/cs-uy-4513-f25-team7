class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
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
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :tag_names)
  end
end

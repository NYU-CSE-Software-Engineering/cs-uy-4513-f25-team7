class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  def index
    @search = params[:search]
    @tag_filter = params[:tag]
    
    @posts = Post.includes(:tags, :votes)
    
    if @search.present?
      @posts = @posts.where("title ILIKE ? OR content ILIKE ?", "%#{@search}%", "%#{@search}%")
    end
    
    if @tag_filter.present?
      @posts = @posts.joins(:tags).where(tags: { name: @tag_filter })
    end
    
    @posts = @posts.left_joins(:votes)
                   .group('posts.id')
                   .order('COALESCE(SUM(votes.value), 0) DESC, posts.created_at DESC')
    
    @posts = @posts.page(params[:page]).per(10)
    
    @all_tags = Tag.order(:name)
  end
  
  def show
    @post = Post.includes(:tags, :votes).find(params[:id])
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    
    if @post.save
      if params[:tags].present?
        tag_names = params[:tags].split(',').map(&:strip).reject(&:blank?)
        tag_names.each do |tag_name|
          tag = Tag.find_or_create_by(name: tag_name.downcase)
          @post.tags << tag unless @post.tags.include?(tag)
        end
      end
      
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @post.update(post_params)
      if params[:tags].present?
        @post.tags.clear
        tag_names = params[:tags].split(',').map(&:strip).reject(&:blank?)
        tag_names.each do |tag_name|
          tag = Tag.find_or_create_by(name: tag_name.downcase)
          @post.tags << tag unless @post.tags.include?(tag)
        end
      end
      
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
    params.require(:post).permit(:title, :content)
  end
end

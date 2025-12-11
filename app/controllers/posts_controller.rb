class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @posts = Post.general.order(created_at: :desc)
    @posts_by_type = @posts.group_by(&:post_type)
    
    # Define the order of categories
    @post_types = [
      { type: "Announcement", icon: "📢", description: "Important news and updates" },
      { type: "Strategy", icon: "⚔️", description: "Competitive tips and team building" },
      { type: "Meta", icon: "📊", description: "Site and community discussion" },
      { type: "Thread", icon: "💬", description: "General discussion" }
    ]
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.order(created_at: :asc)
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  def destroy
    @post = Post.find(params[:id])

    if can_delete_post?(@post)
      @post.destroy
      redirect_to posts_path, notice: "Post was successfully deleted."
    else
      redirect_to @post, alert: "You are not authorized to delete this post."
    end
  end

  private

  def can_delete_post?(post)
    return false unless current_user
    current_user == post.user || current_user.moderator? || current_user.admin?
  end

  def post_params
    params.require(:post).permit(:title, :body, :post_type)
  end
end

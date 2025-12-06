class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: 'Comment posted.'
    else
      redirect_to @post, alert: 'Comment could not be posted.'
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user || current_user.admin? # Assuming admin role exists or will exist
      @comment.destroy
      redirect_to @post, notice: 'Comment was successfully deleted.'
    else
      redirect_to @post, alert: 'You are not authorized to delete this comment.'
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end

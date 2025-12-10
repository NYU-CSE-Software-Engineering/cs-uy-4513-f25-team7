class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: 'Comment posted.'
    else
      flash[:alert] = @comment.errors.full_messages.to_sentence.presence || 'Comment could not be posted.'
      redirect_to @post
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    if can_delete_comment?(@comment)
      @comment.destroy
      redirect_to @post, notice: "Comment was successfully deleted."
    else
      redirect_to @post, alert: "You are not authorized to delete this comment."
    end
  end

  private

  def can_delete_comment?(comment)
    return false unless current_user
    current_user == comment.user || current_user.moderator? || current_user.admin?
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end


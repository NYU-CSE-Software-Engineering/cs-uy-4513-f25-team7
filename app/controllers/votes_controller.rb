class VotesController < ApplicationController
  before_action :set_post
  
  def upvote
    vote(1)
  end
  
  def downvote
    vote(-1)
  end
  
  private
  
  def set_post
    @post = Post.find(params[:post_id])
  end
  
  def vote(value)
    ip_address = request.remote_ip
    
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

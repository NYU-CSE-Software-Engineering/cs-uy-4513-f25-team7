# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :set_review, only: [:edit, :update, :destroy]

  def create
    @review = @team.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      # Notify the team owner
      if @team.user && @team.user != current_user
        Notification.create!(
          user: @team.user,
          actor: current_user,
          event_type: "new_review",
          notifiable: @review
        )
      end
      redirect_to @team, notice: "Review submitted successfully!"
    else
      redirect_to @team, alert: @review.errors.full_messages.to_sentence
    end
  end

  def edit
    unless @review.user == current_user
      redirect_to @team, alert: "You can only edit your own reviews"
    end
  end

  def update
    unless @review.user == current_user
      return redirect_to @team, alert: "You can only edit your own reviews"
    end

    if @review.update(review_params)
      redirect_to @team, notice: "Review updated successfully!"
    else
      render :edit, status: 422
    end
  end

  def destroy
    # Allow user to delete their own review, or moderator/admin to remove any
    unless @review.user == current_user || current_user.moderator? || current_user.admin?
      return redirect_to @team, alert: "You cannot delete this review"
    end

    if current_user.moderator? || current_user.admin?
      # Soft delete for moderation
      @review.soft_delete!
      # Notify the reviewer that their review was removed
      if @review.user != current_user
        Notification.create!(
          user: @review.user,
          actor: current_user,
          event_type: "review_removed",
          notifiable: @team
        )
      end
      redirect_to @team, notice: "Review removed by moderator"
    else
      # Hard delete for user's own review
      @review.destroy
      redirect_to @team, notice: "Review deleted"
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def set_review
    @review = @team.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end

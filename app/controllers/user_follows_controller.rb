class UserFollowsController < ApplicationController
  before_action :ensure_social_login
  before_action :set_followee

  def create
    if @followee == current_user
      return redirect_to @followee, alert: "You cannot follow yourself"
    end

    follow = current_user.followee_relationships.find_by(followee: @followee)
    if follow.present?
      redirect_to @followee, alert: "Already following"
      return
    end

    follow = current_user.followee_relationships.build(followee: @followee)

    if follow.save
      Notification.create!(user: @followee, actor: current_user, event_type: "follow_created", notifiable: follow)
      redirect_to @followee, notice: "Following"
    else
      redirect_to @followee, alert: follow.errors.full_messages.to_sentence
    end
  end

  def destroy
    follow = current_user.followee_relationships.find_by(followee: @followee)
    if follow
      follow.destroy
      redirect_to @followee, notice: "Unfollowed #{@followee.display_name}"
    else
      redirect_to @followee, alert: "You are not following this user"
    end
  end

  private

  def set_followee
    @followee = User.find(params[:user_id])
  end

  def ensure_social_login
    return if user_signed_in?

    flash[:alert] = "Please sign in to continue"
    redirect_to new_user_session_path
  end
end

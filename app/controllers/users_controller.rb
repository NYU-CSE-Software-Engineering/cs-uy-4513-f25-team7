class UsersController < ApplicationController
  before_action :require_login, only: [:index, :update]
  before_action :require_admin, only: [:index, :update]
    def new
      @user = User.new
    end

  def show
    @user = User.find(params[:id])
    @follower_count = @user.followers.count
    @following = user_signed_in? ? current_user.followees.exists?(@user.id) : false
  end

  def create
    @user = User.new(sign_up_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to after_sign_up_path_for(@user), notice: "Welcome, #{@user.email}"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.order(:email)
  end

  # Promote / demote a user

  def update
    @user = User.find(params[:id])
    previous_role = @user.role

    if @user.update(role_params)
      # banner text the Cucumber scenarios look for
      flash[:notice] = "Role updated successfully"

      # detailed messages about the specific user, also checked by Cucumber
      if @user.moderator? && previous_role != "moderator"
        flash[:status_message] = "#{@user.email} is now a moderator"
      elsif @user.user? && previous_role != "user"
        flash[:status_message] = "#{@user.email} is now a user"
      else
        flash[:status_message] = "#{@user.email} role updated"
      end
    else
      # AC4 sad path – they expect both the generic banner...
      flash[:alert] = "Action not allowed"
      # ...and the specific validation text
      flash[:error_message] = @user.errors.full_messages.to_sentence
    end

    redirect_to users_path
  end
  #private methods
  end


  # Role Management page (list users + roles)

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def role_params
    params.require(:user).permit(:role)
  end

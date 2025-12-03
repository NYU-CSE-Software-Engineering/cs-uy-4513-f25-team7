class UsersController < ApplicationController
  before_action :require_login, only: [:index, :update]
  before_action :require_moderator, only: [:index, :update]
    def new
      @user = User.new
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

    if @user.update(role_params)
      # EXACT strings the feature expects:
      #   "ash@poke.com is now a moderator"
      #   "may@poke.com is now a user"
      if @user.moderator?
        flash[:notice] = "#{@user.email} is now a moderator"
      else
        flash[:notice] = "#{@user.email} is now a user"
      end

      # Success banner: .alert-success with "Role updated successfully"
      flash[:success] = "Role updated successfully"

      redirect_to users_path
    else
      # Validation error (e.g., last moderator cannot be demoted)
      message = @user.errors.full_messages.to_sentence.presence ||
                "Action not allowed"

      # Show the detailed reason text (e.g. "There must be at least one moderator on the platform")
      flash[:alert] = message

      # Error banner: .alert-danger with "Action not allowed"
      flash[:error] = "Action not allowed"

      redirect_to users_path
    end
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

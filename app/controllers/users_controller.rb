class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @follower_count = @user.followers.count
    @following = user_signed_in? ? current_user.followees.exists?(@user.id) : false
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to after_sign_up_path_for(@user), notice: "Welcome, #{@user.email}"
    else
      # surface typical validation like “Email has already been taken”
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

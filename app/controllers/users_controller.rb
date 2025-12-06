class UsersController < ApplicationController
  before_action :require_login, only: [:index, :update]
  before_action :require_admin, only: [:index, :update]
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

    # Only admin is allowed here due to before_action :require_admin
    if @user.update(role_params)
      flash[:success] = "#{@user.email} role updated to #{@user.role.titleize}"
    else
      flash[:error] = @user.errors.full_messages.to_sentence
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

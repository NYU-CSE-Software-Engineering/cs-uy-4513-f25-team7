class FavoritesController < ApplicationController
  before_action :ensure_social_login
  before_action :set_favorite, only: :destroy

  def index
    @favorites = current_user.favorites.includes(:favoritable)
  end

  def create
    favoritable = find_favoritable
    return redirect_back fallback_location: favorites_path, alert: "Item not found" unless favoritable

    favorite = current_user.favorites.find_by(favoritable: favoritable)
    if favorite
      redirect_back fallback_location: fallback_location_for(favoritable), alert: "Already favorited"
      return
    end

    favorite = current_user.favorites.build(favoritable: favoritable)
    if favorite.save
      notify_owner(favoritable)
      redirect_back fallback_location: fallback_location_for(favoritable), notice: "Favorited"
    else
      redirect_back fallback_location: fallback_location_for(favoritable), alert: favorite.errors.full_messages.to_sentence
    end
  end

  def destroy
    favoritable = @favorite.favoritable
    @favorite.destroy
    redirect_back fallback_location: fallback_location_for(favoritable), notice: "Favorite removed"
  end

  private

  def set_favorite
    @favorite = current_user.favorites.find(params[:id])
  end

  def find_favoritable
    type = params[:favoritable_type]
    id   = params[:favoritable_id]
    return unless type.present? && id.present?

    allowed_types = ["Team"]
    return unless allowed_types.include?(type)

    type.constantize.find_by(id: id)
  end

  def notify_owner(favoritable)
    return unless favoritable.respond_to?(:owner)
    owner = favoritable.owner
    return if owner == current_user

    Notification.create!(user: owner, actor: current_user, event_type: "favorite_created", notifiable: favoritable)
  end

  def fallback_location_for(favoritable)
    return favorites_path unless favoritable.present?

    polymorphic_path(favoritable)
  rescue StandardError
    favorites_path
  end

  def ensure_social_login
    return if user_signed_in?

    flash[:alert] = "Please sign in to continue"
    redirect_to new_user_session_path
  end
end

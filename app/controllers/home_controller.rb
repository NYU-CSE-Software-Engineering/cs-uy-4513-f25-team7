class HomeController < ApplicationController
  def index
    @teams = current_user&.teams&.order(updated_at: :desc) || []

    @user_query   = nil
    @user_results = []

    return unless user_signed_in?

    @user_query = params[:user_query].to_s.strip
    return if @user_query.blank?

    #Don’t show yourself in results
    @user_results = User
                      .lookup_query(@user_query)
                      .where.not(id: current_user.id)
                      .limit(10)
  end
end

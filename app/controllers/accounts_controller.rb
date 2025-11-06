class AccountsController < ApplicationController
  before_action :require_login

  def edit
    # renders settings page
  end
end

Rails.application.routes.draw do
  root "home#index"

  # Registration (we aliased path name so your steps work)
  get  "/register", to: "users#new",    as: :new_user_registration
  post "/users",    to: "users#create", as: :users

  # Sessions (plural)
  get    "/login",  to: "sessions#new",     as: :new_user_session
  post   "/login",  to: "sessions#create",  as: :user_session
  delete "/logout", to: "sessions#destroy", as: :destroy_user_session

  # For enabling 2 factor
  get "/settings", to: "accounts#edit", as: :edit_user_registration

  get  "/two_factor/new", to: "two_factor#new",    as: :new_two_factor
  post "/two_factor",     to: "two_factor#create", as: :two_factor
end

Rails.application.routes.draw do
  # Home
  root "home#index"

  # Registration (UsersController)
  get  "/register", to: "users#new",    as: :new_user_registration  # alias for your steps
  post "/users",    to: "users#create", as: :users

  # (Optional now; for later login scenarios we’ll use SessionsController)
  get  "/login",  to: "sessions#new",     as: :new_user_session
  post "/login",  to: "sessions#create",  as: :user_session
  delete "/logout", to: "sessions#destroy", as: :destroy_user_session
end

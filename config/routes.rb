Rails.application.routes.draw do
  # Healthcheck used by main branch CI
  get "up" => "rails/health#show", as: :rails_health_check

  # Species/feed routes from main branch
  get    "/species/:name",         to: "species#show",    as: :species
  post   "/species/:name/follow",  to: "follows#create",  as: :species_follow
  delete "/species/:name/follow",  to: "follows#destroy"
  post   "/species/:name/posts",   to: "species#create_post", as: :species_posts
  # get "/feed", to: "feed#show", as: :feed
  get "/feed", to: "feed#index", as: :feed
  get "/species", to: "species#index", as: :species_index

  namespace :api do
    namespace :lookup do
      get :species, to: "species#index"
    end
  end

  resources :posts do
    member do
      post :upvote
      post :downvote
    end
    resources :comments, only: [:create, :destroy]
  end

  # Root now points to the user home/dashboard but species index is still available
  root "home#index"

  # User registration + moderation (role management)
  resources :users, only: [:new, :create, :index, :update, :destroy]
  # Registration (aliased path name so cucumber steps work)
  get  "/register", to: "users#new",    as: :new_user_registration

  # Sessions (plural)
  get    "/login",  to: "sessions#new",     as: :new_user_session
  post   "/login",  to: "sessions#create",  as: :user_session
  delete "/logout", to: "sessions#destroy", as: :destroy_user_session

  # For enabling 2 factor and profile settings
  get   "/settings", to: "accounts#edit",   as: :edit_user_registration
  patch "/settings", to: "accounts#update", as: :update_profile

  # Admin setup (first admin promotion)
  get  "/admin/setup",  to: "accounts#admin_setup",  as: :admin_setup
  post "/admin/setup",  to: "accounts#become_admin", as: :become_admin
  
  # Admin panel
  get "/admin", to: "users#index", as: :admin_panel

  get  "/two_factor/new", to: "two_factor#new",    as: :new_two_factor
  post "/two_factor",     to: "two_factor#create", as: :two_factor
  get  "/two_factor/verify", to: "two_factor#prompt",      as: :two_factor_verify
  post "/two_factor/verify", to: "two_factor#verify_login"

  get  "/auth/google_oauth2/callback", to: "sessions#google",  as: :google_oauth2_callback
  get  "/auth/failure",                to: "sessions#failure"
  get "/auth/:provider/callback", to: "sessions#google"

  resources :users, only: [:show] do
    resource :follow, only: [:create, :destroy], controller: "user_follows"
  end

  # team builder
  resources :teams, only: %i[new destroy create edit update show] do
    resources :reviews, only: [:create, :edit, :update, :destroy]
  end
  resources :favorites, only: [:index, :create, :destroy]
  resources :notifications, only: [:index]

  resources :messages, only: [:index, :new, :create, :show]
end

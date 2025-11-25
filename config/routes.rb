Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get    "/species/:name",         to: "species#show",    as: :species
  post   "/species/:name/follow",  to: "follows#create",  as: :species_follow
  delete "/species/:name/follow",  to: "follows#destroy"

  get "/feed", to: "feed#show", as: :feed

  get "/species", to: "species#index", as: :species_index


  root "species#index"
  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :lookup do
      get :species, to: "species#index"
    end
  end

end

# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "teams#index", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  resources :teams, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      post  :validate
      patch :publish
      patch :unpublish
    end
  end

  resources :posts do
    resources :comments, only: [:create]
  end

  # (Optional) legacy autocomplete route you added
  get "/dex/species", to: "dex_autocomplete#species"

  # API lookups for autocomplete
  namespace :api do
    get "lookup/species",   to: "lookup#species"
    get "lookup/moves",     to: "lookup#moves"
    get "lookup/items",     to: "lookup#items"
    get "lookup/abilities", to: "lookup#abilities"
    get "lookup/natures",   to: "lookup#natures"
    get "lookup/learnset",  to: "lookup#learnset"
  end
end

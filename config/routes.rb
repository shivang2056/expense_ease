Rails.application.routes.draw do
  devise_for :users

  resources :expenses do
    resources :items do
      resources :splits
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/all_expenses", to: "dashboard#all_expenses"
  get "/test", to: "dashboard#test"
  post :search_user, to: "dashboard#search_user", as: :search_user
  get '/append_user/:id', to: 'dashboard#append', as: :append_user
  get "/reload_split_by_accordion", to: "dashboard#reload_split_by_accordion", as: :reload_split_by_accordion

  # Defines the root path route ("/")
  root "dashboard#index"
end

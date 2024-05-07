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

  post :search_user, to: "dashboard#search_user", as: :search_user
  get '/append_user/:id', to: 'dashboard#append', as: :append_user

  # Defines the root path route ("/")
  root "dashboard#index"
end

require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    resources :loan_requests, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
        get :adjust
        post :adjustment_update
      end
    end
  end
  devise_for :users
  resources :users , only: [:new, :create]
  resources :loan_requests do
    member do
      patch :accept
      patch :reject
      patch :confirm
      patch :close
      get :readjustment
      post :readjustment_update
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index"
  mount Sidekiq::Web => '/sidekiq'

end

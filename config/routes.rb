Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  resources :users, only: :create
  resource :account, only: [:show, :update]

  resources :teams, only: [:index, :create, :update] do
    resources :memberships, only: [:create, :update, :destroy], shallow: true
    resources :notes, shallow: true
  end
end

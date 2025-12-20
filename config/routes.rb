require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'pages#home'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/auth/:provider/callback', to: 'sessions#google_auth'
  get '/auth/failure', to: 'sessions#failure'

  devise_for :users


  Sidekiq::Web.app_url = '/'
  authenticate :admin_user do
    # Sidekiq::Throttled::Web.enhance_queues_tab!

    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do
    namespace :v1 do
      post 'sign_up', to: 'auth#sign_up'
      post 'sign_in', to: 'auth#sign_in'

      resource :user, only: [:show, :update]

      resources :brands, only: [:index]
      resources :target_audiences, only: [:index]
      resources :categories, only: [:index]
      resources :colors, only: [:index]
      resources :sizes, only: [:index]
      resources :user_photos, only: [:index, :create, :destroy] do
        post :try_on_shoe
      end
      resources :shoes, only: [:index] do
        get :redirect_from_email
        post :like
        post :dislike
        collection do
          get  :liked
        end
      end

      resources :searches, only: [:create, :index]
    end
  end
end


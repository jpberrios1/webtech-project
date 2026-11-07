Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "roomies#home"
  resource :session, only: %i[new create destroy]
  resources :passwords, only: %i[new create edit update], param: :token
  resources :users, only: [:new, :create]
  resource :profile, only: [:show, :edit, :update]

  resources :neighborhoods
  resources :amenities
  resources :visits
  resources :reviews

  resources :properties do
      resources :listings, only: [ :new, :create ]
  end

  resources :listings, except: [ :new, :create ] do
      resources :applications, only: [ :create ]
  end

  resources :applications, except: [ :new, :create ]

  # Public JSON API. The version is part of the URL, so a future v2 can live next to v1.
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :listings, only: [ :index, :show ]
      resources :neighborhoods, only: [ :index ]
      resources :amenities, only: [ :index ]
      resources :shared_spaces, only: [ :index ]

      # Anything else under /api/v1 answers a JSON 404 instead of Rails' HTML error page
      match "*path", to: "base#route_not_found", via: :all
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

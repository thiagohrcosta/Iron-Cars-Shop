Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  root "pages#home"
  get "cars", to: "cars#index", as: :cars
  get "cars/:id", to: "cars#show", as: :car

  get "dashboard", to: "dashboard_redirects#show"

  namespace :admin do
    get "dashboard", to: "dashboards#show"
  end

  namespace :user do
    get "dashboard", to: "dashboards#show"
    resources :vehicles, only: [ :index, :new, :create ] do
      member do
        post :publish
      end
    end
    get "analytics", to: "analytics#show"
    get "analytics/data", to: "analytics#data"
    post "billing/checkout", to: "billing#create_checkout_session", as: :billing_checkout

    resources :negotiations, only: [ :index, :show, :create ] do
      member do
        post :make_offer
        patch :accept_offer
        patch :reject_offer
      end

      resources :messages, only: :create, controller: "negotiation_messages"
    end
  end

  post "webhooks/stripe", to: "webhooks/stripe#create"
  post "api/v1/webhooks/stripe", to: "webhooks/stripe#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end

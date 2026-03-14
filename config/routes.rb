Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: { registrations: "users/registrations" }

  root "pages#home"
  get "cars", to: "cars#index", as: :cars
  get "cars/:id", to: "cars#show", as: :car
  post "lead_chat/messages", to: "lead_chat_messages#create", as: :lead_chat_messages
  get "lead-access/:token", to: "public/lead_negotiations#show", as: :public_lead_negotiation
  post "lead-access/:token/messages", to: "public/lead_negotiation_messages#create", as: :public_lead_negotiation_messages

  namespace :api do
    namespace :v1 do
      resources :listings, only: :index
    end
  end

  get "dashboard", to: "dashboard_redirects#show"

  namespace :admin do
    get "dashboard", to: "dashboards#show"
    resources :leads, only: [ :index, :create, :update ] do
      member do
        post :distribute
        post :confirm_distribution
        post :retry_distribution
        patch :update_status
      end
    end
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

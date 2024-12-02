Rails.application.routes.draw do
  devise_for :users
  resources :articles
  get "tags/search", to: "tags#search"
  get "categories/index"
  get "categories/new"
  get "categories/edit"
  get "categories/search", to: "categories#search"

  resources :articles do
    resource :cover_image, only: :destroy, module: :articles
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#home"

  post "uploads/upload_image", to: "uploads#upload_image"
  get "temp-file/:filename", to: "uploads#serve_temp_file", as: :serve_temp_file
end

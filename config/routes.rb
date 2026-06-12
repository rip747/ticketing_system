Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "login" => "sessions#new", as: :login
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout

  # Registration
  get "register" => "users#new", as: :register
  post "register" => "users#create"

  # Profile
  get "profile" => "users#show", as: :profile
  get "profile/edit" => "users#edit", as: :edit_profile
  patch "profile" => "users#update"
  put "profile" => "users#update"

  # Dashboard
  root "dashboard#index"

  # Tickets
  resources :tickets do
    member do
      post :assign
      patch :close
      patch :reopen
    end
    resources :comments, only: [ :create, :destroy ]
  end

  # Dynamic category loading
  get "departments/:id/categories", to: "departments#categories", as: :department_categories

  # Organization Admin namespace (for org_admins managing their org)
  namespace :admin do
    root "dashboard#index"
    resources :departments
    resources :categories
    resources :users
  end

  # System Admin namespace (for sys_admins managing the whole platform)
  namespace :system do
    # Separate login for system administrators
    get "login" => "sessions#new", as: :login
    post "login" => "sessions#create"
    delete "logout" => "sessions#destroy", as: :logout

    root "dashboard#index"
    resources :organizations
  end
end

Rails.application.routes.draw do
  root "prescriptions#index"

  devise_for :users, path: "auth", path_names: { sign_in: "login", sign_out: "logout" }

  namespace :admin do
    root "prescriptions#index"
    resources :prescriptions
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

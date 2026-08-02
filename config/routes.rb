Rails.application.routes.draw do
  devise_for :users

  # Secure the Motor Admin engine. The engine owns its nested /data routes.
  authenticate :user, ->(user) { user.admin? } do
    mount Motor::Admin => "/motor_admin"
  end

  # The custom dashboard is the signed-in landing page.
  root to: "dashboard#index"
  get "/dashboard", to: "dashboard#index"

  # INTELIXA demo page; authentication is enforced by ApplicationController.
  get "intelixa", to: "pages#intelixa"
end

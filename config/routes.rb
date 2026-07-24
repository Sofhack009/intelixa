Rails.application.routes.draw do
  devise_for :users
  
  # Secure the Motor Admin engine
  authenticate :user do
    mount Motor::Admin => '/motor_admin'
    get '/motor_admin(/*path)', to: redirect('/motor_admin')
  end

  # The ONE AND ONLY root route, pointing to your custom dashboard
  root to: "dashboard#index"
  get "/dashboard", to: "dashboard#index"

  # INTELIXA demo page
  get 'intelixa', to: 'pages#intelixa'
end

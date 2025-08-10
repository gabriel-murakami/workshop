Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: "web" do
    scope module: "controllers" do
      # ======================
      # Auth
      # ======================
      post "/login", to: "auth#login"

      # ======================
      # Customers
      # ======================
      resources :customers, only: %i[index create update destroy]
      get "customers/:document_number", to: "customers#show"
      patch "customers/:document_number/add_vehicle", to: "customers#add_vehicle"

      # ======================
      # Vehicles
      # ======================
      resources :vehicles, only: %i[index create update destroy]
      get "vehicles/:license_plate", to: "vehicles#show"

      # ======================
      # Services
      # ======================
      resources :services, only: %i[index create update destroy show]

      # ======================
      # Auto Parts
      # ======================
      resources :auto_parts, only: %i[index create update destroy show]
      post "auto_parts/:id/add", to: "auto_parts#add_auto_parts"
      post "auto_parts/:id/remove", to: "auto_parts#remove_auto_parts"

      # ======================
      # Metrics
      # ======================
      resources :metrics, only: %i[index]

      # ======================
      # SerivceOrders
      # ======================
      resources :service_orders, only: %i[index show]
      post "service_orders/:id/add_auto_parts", to: "service_orders#add_auto_parts"
      post "service_orders/:id/add_services", to: "service_orders#add_services"
      post "service_orders/:id/finish", to: "service_orders#finish"
      post "service_orders/:id/start", to: "service_orders#start"
    end
  end
end

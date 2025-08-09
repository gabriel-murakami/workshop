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
      # Orders (exemplo futuro)
      # ======================
      # patch "orders/:order_id/products", to: "orders#add_product"
      # patch "orders/:order_id/products/:product_id", to: "orders#change_product_quantity"
      # delete "orders/:order_id/products/:product_id", to: "orders#remove_product"
    end
  end
end

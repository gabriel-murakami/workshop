Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  scope module: "web" do
    scope module: "controllers" do
      get "up" => "rails/health#show", as: :rails_health_check

      # Auth
      post "/login", to: "auth#login"

      # resources :customers
      # resources :service_orders, only: %i[index show]

      # Commands
      post "customers", to: "customers#create"
      patch "customers/:document_number/add_vehicle", to: "customers#add_vehicle"

      # patch "orders/:order_id/products", to: "orders#add_product"
      # patch "orders/:order_id/products/:product_id", to: "orders#change_product_quantity"
      # delete "orders/:order_id/products/:product_id", to: "orders#remove_product"

      # Queries
      get "customers", to: "customers#index"
      get "customers/:document_number", to: "customers#show"
      # get "orders", to: "orders#find_last_orders", constraints: lambda { |request| request.params.key?(:last_orders) }
      # get "orders", to: "orders#find_orders_per_users", constraints: lambda { |request| request.params.key?(:orders_per_users) }

      get "vehicles", to: "vehicles#index"
      get "vehicles/:license_plate", to: "vehicles#show"
    end
  end
end

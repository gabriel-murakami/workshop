Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: "web" do
    scope module: "controllers" do
      post "/login", to: "auth#login"

      scope controller: :customers do
        resources :customers, only: %i[index create update destroy]
        get "customers/:document_number", action: :show
        patch "customers/:document_number/add_vehicle", action: :add_vehicle
      end

      scope controller: :vehicles do
        resources :vehicles, only: %i[index create update destroy]
        get "vehicles/:license_plate", action: :show
      end

      scope controller: :services do
        resources :services, only: %i[index create update destroy show]
      end

      scope controller: :auto_parts do
        resources :auto_parts, only: %i[index create update destroy show]
        post "auto_parts/:id/add", action: :add_auto_parts
        post "auto_parts/:id/remove", action: :remove_auto_parts
      end

      scope controller: :metrics do
        resources :metrics, only: %i[index]
      end

      scope controller: :service_orders do
        resources :service_orders, only: %i[index show]
        post "service_orders/:id/add_auto_parts", action: :add_auto_parts
        post "service_orders/:id/add_services", action: :add_services
        post "service_orders/:id/finish", action: :finish
        post "service_orders/:id/start", action: :start
        post "service_orders/:id/send_to_diagnosis", action: :send_to_diagnosis
        post "service_orders/:id/send_to_approval", action: :send_to_approval
      end

      scope controller: :budgets do
        resources :budgets, only: %i[index show]
        post "budgets/:id/approve", action: :approve
        post "budgets/:id/reject", action: :reject
      end
    end
  end
end

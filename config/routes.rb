Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end

  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: "web" do
    scope module: "controllers" do
      namespace :internal do
        scope controller: :users do
          post "users/:document_number", action: :create
        end
      end

      post "/login", to: "api/auth#login"

      namespace :webhooks do
        scope controller: :payments do
          post "payments", action: :create
        end
      end

      namespace :api do
        scope controller: :payments do
          resources :payments, only: %i[index]
        end

        scope controller: :metrics do
          resources :metrics, only: %i[index]
        end

        scope controller: :service_orders do
          resources :service_orders, only: %i[index show create]
          get "service_orders/:id/current_status", action: :current_status
          post "service_orders/open", action: :open
          post "service_orders/:id/add_products", action: :add_products
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
end

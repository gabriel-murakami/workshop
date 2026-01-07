module Web
  module Controllers
    module Internal
      class CustomersController < Web::Controllers::ApplicationController
        before_action :internal_auth!

        def show
          customer = Application::Customer::CustomerApplication.new.find_by_document_number(customer_params[:document_number])

          head :ok if customer.present?
        end

        private

        def internal_auth!
          head :unauthorized unless request.headers["X-Internal-Token"] == ENV["INTERNAL_AUTH_TOKEN"]
        end
      end
    end
  end
end

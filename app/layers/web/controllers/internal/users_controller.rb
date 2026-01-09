module Web
  module Controllers
    module Internal
      class UsersController < Web::Controllers::ApplicationController
        before_action :internal_auth!

        def create
          user = Domain::ServiceOrder::User.find_by(document_number: params[:document_number])

          if user&.authenticate(params[:password])
            head :ok
          else
            head :unauthorized
          end
        end

        private

        def internal_auth!
          head :unauthorized unless request.headers["X-Internal-Token"] == ENV["INTERNAL_AUTH_TOKEN"]
        end
      end
    end
  end
end

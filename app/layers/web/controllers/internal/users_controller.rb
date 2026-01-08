module Web
  module Controllers
    module Internal
      class UsersController < Web::Controllers::ApplicationController
        before_action :internal_auth!

        def show
          user = Domain::ServiceOrder::User.find_by!(document_number: params[:document_number])

          head :ok if user.present?
        end

        private

        def internal_auth!
          head :unauthorized unless request.headers["X-Internal-Token"] == ENV["INTERNAL_AUTH_TOKEN"]
        end
      end
    end
  end
end

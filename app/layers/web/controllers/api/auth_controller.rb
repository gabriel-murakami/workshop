module Web
  module Controllers
    module Api
      class AuthController < Web::Controllers::ApplicationController
        wrap_parameters false

        include ::Web::Controllers::Concerns::Authenticable

        private

        SECRET_KEY = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]

        def user
          @user ||= Domain::ServiceOrder::User.find_by(email: permitted_params[:email])
        end

        def encode_jwt(payload, exp = 24.hours.from_now)
          payload[:exp] = exp.to_i
          JWT.encode(payload, SECRET_KEY, "HS256")
        end

        def permitted_params
          params.permit(:email, :password)
        end
      end
    end
  end
end

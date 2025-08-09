# require_dependency Rails.root.join("app/layers/web/controllers/concerns/authenticable").to_s

module Web
  module Controllers
    class AuthController < ApplicationController
      skip_before_action :authenticate_request!, only: [ :login ]

      def login
        user = Domain::ServiceOrder::User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = encode_jwt(user_id: user.id)
          render json: { token: token }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      SECRET_KEY = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]

      def encode_jwt(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY, "HS256")
      end
    end
  end
end

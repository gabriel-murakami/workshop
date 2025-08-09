module Web
  module Controllers
    module Concerns
      module Authenticable
        extend ActiveSupport::Concern

        SECRET_KEY = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]

        included do
          before_action :authenticate_request!
        end

        private

        def authenticate_request!
          header = request.headers["Authorization"]
          token = header&.split(" ")&.last
          decoded = decode_jwt(token)
          @current_user = Domain::ServiceOrder::User.find(decoded[:user_id])
        rescue ActiveRecord::RecordNotFound, JWT::DecodeError
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        def decode_jwt(token)
          decoded_token = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
          HashWithIndifferentAccess.new(decoded_token[0])
        end

        attr_reader :current_user
      end
    end
  end
end

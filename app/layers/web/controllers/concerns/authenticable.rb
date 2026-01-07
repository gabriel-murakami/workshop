module Web
  module Controllers
    module Concerns
      module Authenticable
        extend ActiveSupport::Concern

        SECRET_KEY = Rails.application.credentials.jwt_secret || ENV.fetch("JWT_SECRET")

        JWT_ISSUER   = "auth.local"
        JWT_AUDIENCE = "api.local"
        JWT_ALGO     = "HS256"

        included do
          before_action :authenticate_request!
        end

        private

        def authenticate_request!
          token = bearer_token
          payload = decode_jwt(token)

          @current_user = Domain::ServiceOrder::User.find_by!(document_number: payload[:cpf])
        rescue ActiveRecord::RecordNotFound
          unauthorized!("User not found")
        rescue JWT::ExpiredSignature
          unauthorized!("Token expired")
        rescue JWT::DecodeError, JWT::InvalidIssuerError, JWT::InvalidAudError
          unauthorized!("Invalid token")
        end

        def bearer_token
          header = request.headers["Authorization"]
          return nil unless header&.start_with?("Bearer ")

          header.split(" ").last
        end

        def decode_jwt(token)
          raise JWT::DecodeError, "Missing token" unless token

          decoded_token = JWT.decode(
            token,
            SECRET_KEY,
            true,
            algorithm: JWT_ALGO,
            iss: JWT_ISSUER,
            verify_iss: true,
            aud: JWT_AUDIENCE,
            verify_aud: true
          )

          HashWithIndifferentAccess.new(decoded_token.first)
        end

        def unauthorized!(message = "Unauthorized")
          render json: { error: message }, status: :unauthorized
        end

        attr_reader :current_user
      end
    end
  end
end

require_dependency Rails.root.join("app/layers/web/controllers/concerns/authenticable").to_s

module Web
  module Controllers
    class ApplicationController < ActionController::API
      include Authenticable
      # rescue_from Exception do |e|
      #   Rails.logger.error("Error message: #{e.message}")

      #   render json: { error: "Unexpected Error" }, status: :internal_server_error
      # end

      rescue_from Exceptions::CustomerException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end

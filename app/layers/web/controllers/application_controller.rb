# require_dependency Rails.root.join("app/layers/web/controllers/concerns/authenticable").to_s

module Web
  module Controllers
    class ApplicationController < ActionController::API
      include ::Web::Controllers::Concerns::Authenticable

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      rescue_from Exceptions::CustomerException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      rescue_from Exceptions::AutoPartException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end

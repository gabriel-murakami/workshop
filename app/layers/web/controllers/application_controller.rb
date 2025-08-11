module Web
  module Controllers
    class ApplicationController < ActionController::API
      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      rescue_from Exceptions::CustomerException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      rescue_from Exceptions::ProductException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end

      rescue_from Exceptions::ServiceOrderException do |e|
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end

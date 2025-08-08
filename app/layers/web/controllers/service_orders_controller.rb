module Web
  module Controllers
    class ServiceOrdersController < ApplicationController
      def index
        render json: Domain::ServiceOrder::ServiceOrder.all
      end

      def show
        render json: Domain::ServiceOrder::ServiceOrder.find(params[:id])
      end
    end
  end
end

module Web
  module Controllers
    class VehiclesController < ApplicationController
      include Authenticable

      def index
        vehicles = Infra::QueryObjects::VehiclesQuery.all_vehicles

        render json: vehicles
      end

      def show
        vehicle = Infra::Repositories::VehicleRepository.new.find_vehicle_by_license_plate(
          permitted_params[:license_plate]
        )

        render json: vehicle
      end

      def create
      end

      def update
      end

      def destroy
      end

      private

      def permitted_params
        params.permit(:license_plate, :brand, :model, :year)
      end
    end
  end
end

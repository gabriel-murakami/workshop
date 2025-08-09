module Web
  module Controllers
    class VehiclesController < ApplicationController
      include ::Web::Controllers::Concerns::Authenticable

      def index
        vehicles = Infra::Repositories::VehicleRepository.new.find_all

        render json: vehicles
      end

      def show
        vehicle = Infra::Repositories::VehicleRepository.new.find_vehicle_by_license_plate(
          vehicle_params[:license_plate]
        )

        render json: vehicle
      end

      def create
        vehicle = Application::Customer::VehicleApplication.new.create_vehicle(
          Application::Customer::Commands::CreateVehicleCommand.new(vehicle: vehicle_params)
        )

        render json: vehicle
      end

      def update
        command = Application::Customer::Commands::UpdateVehicleCommand.new(vehicle_attributes: vehicle_params)
        vehicle = Application::Customer::VehicleApplication.new.update_vehicle(command)

        render json: vehicle
      end

      def destroy
        command = Application::Customer::Commands::DeleteVehicleCommand.new(vehicle_id: vehicle_params[:id])

        Application::Customer::VehicleApplication.new.delete_vehicle(command)

        head :ok
      end

      private

      def vehicle_params
        params.permit(:id, :license_plate, :brand, :model, :year, :customer_id)
      end
    end
  end
end

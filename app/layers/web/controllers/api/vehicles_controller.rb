module Web
  module Controllers
    module Api
      class VehiclesController < AuthController
        def index
          render json: Application::Customer::VehicleApplication.new.find_all,
            each_serializer: ::Serializers::Domain::Customer::VehicleSerializer
        end

        def show
          vehicle = Application::Customer::VehicleApplication.new.find_by_license_plate(
            vehicle_params[:license_plate]
          )

          render json: vehicle,
            serializer: ::Serializers::Domain::Customer::VehicleSerializer
        end

        def create
          vehicle = Application::Customer::VehicleApplication.new.create_vehicle(
            Application::Customer::Commands::CreateVehicleCommand.new(vehicle: vehicle_params)
          )

          render json: vehicle, status: :created,
            serializer: ::Serializers::Domain::Customer::VehicleSerializer
        end

        def update
          command = Application::Customer::Commands::UpdateVehicleCommand.new(vehicle_attributes: vehicle_params)
          vehicle = Application::Customer::VehicleApplication.new.update_vehicle(command)

          render json: vehicle,
            serializer: ::Serializers::Domain::Customer::VehicleSerializer
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
end

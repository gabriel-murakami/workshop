module Application
  module Customer
    class VehicleApplication
      def initialize(repositories = {})
        @vehicle_repository = repositories.fetch(:vehicle) { Infra::Repositories::VehicleRepository.new }
      end

      def find_all
        @vehicle_repository.find_all
      end

      def find_vehicle_by_license_plate(license_plate)
        @vehicle_repository.find_vehicle_by_license_plate(license_plate)
      end

      def create_vehicle(create_vehicle_command)
        vehicle = Domain::Customer::Vehicle.new(create_vehicle_command.vehicle)

        ActiveRecord::Base.transaction do
          @vehicle_repository.save(vehicle)

          vehicle
        end
      end

      def delete_vehicle(delete_vehicle_command)
        vehicle = @vehicle_repository.find_by_id(delete_vehicle_command.vehicle_id)

        ActiveRecord::Base.transaction do
          @vehicle_repository.delete(vehicle)
        end
      end

      def update_vehicle(update_vehicle_command)
        vehicle = @vehicle_repository.find_by_id(update_vehicle_command.vehicle_attributes[:id])

        ActiveRecord::Base.transaction do
          @vehicle_repository.update(vehicle, update_vehicle_command.vehicle_attributes)

          vehicle
        end
      end
    end
  end
end

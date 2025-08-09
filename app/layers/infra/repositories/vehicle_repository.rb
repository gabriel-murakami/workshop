module Infra
  module Repositories
    class VehicleRepository
      def initialize(model = {})
        @vehicle = model.fetch(:vehicle) { Domain::Customer::Vehicle }
      end

      def save(vehicle)
        vehicle.save!
      end

      def delete(vehicle)
        vehicle.destroy
      end

      def update(vehicle, vehicle_attributes)
        vehicle.update!(vehicle_attributes)
      end

      def find_vehicle_by_license_plate(license_plate)
        @vehicle.find_by!(license_plate: license_plate)
      end

      def find_by_id(vehicle_id)
        @vehicle.find_by!(id: vehicle_id)
      end

      def find_all
        @vehicle.all
      end
    end
  end
end

module Infra
  module Repositories
    class VehicleRepository
      def initialize(model = {})
        @vehicle = model.fetch(:vehicle) { Domain::Customer::Vehicle }
      end

      def save(vehicle)
        vehicle.save
      end

      def find_vehicle_by_license_plate(license_plate)
        @vehicle.find_by(license_plate: license_plate)
      end
    end
  end
end

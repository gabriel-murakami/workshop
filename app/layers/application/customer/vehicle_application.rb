module Application
  module Customer
    class VehicleApplication
      def initialize(client: Infra::Clients::CustomerServiceClient.new)
        @client = client
      end

      def find_by_license_plate(license_plate)
        @client.vehicle_by_license_plate(license_plate)
      end
    end
  end
end

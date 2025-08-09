module Application
  module Customer
    module Commands
      class AddVehicleCommand
        attr_accessor :customer_document_number, :vehicle_license_plate

        def initialize(customer_document_number:, vehicle_license_plate:)
          @customer_document_number = customer_document_number
          @vehicle_license_plate = vehicle_license_plate
        end
      end
    end
  end
end

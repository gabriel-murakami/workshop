module Application
  module Customer
    module Commands
      class UpdateVehicleCommand
        attr_accessor :vehicle_attributes

        def initialize(vehicle_attributes:)
          @vehicle_attributes = vehicle_attributes
        end
      end
    end
  end
end

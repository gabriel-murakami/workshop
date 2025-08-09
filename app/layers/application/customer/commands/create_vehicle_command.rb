module Application
  module Customer
    module Commands
      class CreateVehicleCommand
        attr_accessor :vehicle

        def initialize(vehicle:)
          @vehicle = vehicle
        end
      end
    end
  end
end

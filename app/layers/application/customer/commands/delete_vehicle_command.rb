module Application
  module Customer
    module Commands
      class DeleteVehicleCommand
        attr_accessor :vehicle_id

        def initialize(vehicle_id:)
          @vehicle_id = vehicle_id
        end
      end
    end
  end
end

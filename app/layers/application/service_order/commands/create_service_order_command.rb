module Application
  module ServiceOrder
    module Commands
      class CreateServiceOrderCommand
        attr_accessor :customer_id, :vehicle_id

        def initialize(customer_id:, vehicle_id:)
          @customer_id = customer_id
          @vehicle_id = vehicle_id
        end
      end
    end
  end
end

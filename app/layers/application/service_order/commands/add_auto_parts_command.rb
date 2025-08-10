module Application
  module ServiceOrder
    module Commands
      class AddAutoPartsCommand
        attr_accessor :service_order_id, :auto_parts_params

        def initialize(service_order_id:, auto_parts_params:)
          @service_order_id = service_order_id
          @auto_parts_params = auto_parts_params
        end
      end
    end
  end
end

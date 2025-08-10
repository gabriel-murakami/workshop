module Application
  module ServiceOrder
    module Commands
      class AddServicesCommand
        attr_accessor :service_order_id, :services_codes

        def initialize(service_order_id:, services_codes:)
          @service_order_id = service_order_id
          @services_codes = services_codes
        end
      end
    end
  end
end

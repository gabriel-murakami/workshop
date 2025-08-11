module Application
  module ServiceOrder
    module Commands
      class CreateBudgetCommand
        attr_accessor :service_order_id

        def initialize(service_order_id:)
          @service_order_id = service_order_id
        end
      end
    end
  end
end

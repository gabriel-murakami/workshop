module Application
  module ServiceOrder
    module Commands
      class AddAutoPartsCommand
        attr_accessor :service_order_id, :auto_parts_skus

        def initialize(service_order_id:, auto_parts_skus:)
          @service_order_id = service_order_id
          @auto_parts_skus = auto_parts_skus
        end
      end
    end
  end
end

module Application
  module ServiceOrder
    module Commands
      class AddProductsCommand
        attr_accessor :service_order_id, :products_params

        def initialize(service_order_id:, products_params:)
          @service_order_id = service_order_id
          @products_params = products_params
        end
      end
    end
  end
end

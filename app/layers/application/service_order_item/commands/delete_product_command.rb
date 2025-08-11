module Application
  module ServiceOrderItem
    module Commands
      class DeleteProductCommand
        attr_accessor :product_id

        def initialize(product_id:)
          @product_id = product_id
        end
      end
    end
  end
end

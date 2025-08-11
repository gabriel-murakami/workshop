module Application
  module ServiceOrderItem
    module Commands
      class UpdateProductCommand
        attr_accessor :product_attributes

        def initialize(product_attributes:)
          @product_attributes = product_attributes
        end
      end
    end
  end
end

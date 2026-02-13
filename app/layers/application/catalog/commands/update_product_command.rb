module Application
  module Catalog
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

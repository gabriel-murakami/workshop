module Application
  module Catalog
    module Commands
      class CreateProductCommand
        attr_accessor :product

        def initialize(product:)
          @product = product
        end
      end
    end
  end
end

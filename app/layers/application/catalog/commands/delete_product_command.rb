module Application
  module Catalog
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

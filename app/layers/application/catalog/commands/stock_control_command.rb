module Application
  module Catalog
    module Commands
      class StockControlCommand
        attr_accessor :product_id, :stock_change

        def initialize(product_id:, stock_change:)
          @product_id = product_id
          @stock_change = stock_change
        end
      end
    end
  end
end

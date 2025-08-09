module Application
  module ServiceOrderItem
    module Commands
      class StockControlCommand
        attr_accessor :auto_part_id, :stock_change

        def initialize(auto_part_id:, stock_change:)
          @auto_part_id = auto_part_id
          @stock_change = stock_change
        end
      end
    end
  end
end

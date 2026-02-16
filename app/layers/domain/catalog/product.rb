module Domain
  module Catalog
    class Product < Infra::Models::ApplicationRecord
      validates :sku, presence: true, uniqueness: true,
                      format: { with: /\AAP\d{3}\z/, message: "must be in the format 'AP' followed by 3 digits" }
      validates :name, presence: true
      validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

      def add_product(stock_change)
        self.stock_quantity += stock_change
      end

      def remove_product(stock_change)
        if stock_change > self.stock_quantity
          raise ::Exceptions::ProductException.new("The amount removed cannot be greater than the total in stock")
        end

        self.stock_quantity -= stock_change
      end
    end
  end
end

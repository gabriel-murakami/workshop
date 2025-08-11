module Infra
  module QueryObjects
    class ProductsQuery < Domain::ServiceOrderItem::Product
      class << self
        def find_products_by_sku(skus)
          self.where(sku: skus)
        end
      end
    end
  end
end

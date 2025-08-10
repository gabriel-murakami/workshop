module Infra
  module QueryObjects
    class AutoPartsQuery < Domain::ServiceOrderItem::AutoPart
      class << self
        def find_auto_parts_by_sku(skus)
          self.where(sku: skus)
        end
      end
    end
  end
end

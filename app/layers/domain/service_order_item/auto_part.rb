module Domain
  module ServiceOrderItem
    class AutoPart < Infra::Models::ApplicationRecord
      has_many :service_order_items, as: :item

      validates :name, presence: true
      validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :base_price, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end

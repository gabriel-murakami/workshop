module Domain
  module ServiceOrderItem
    class Service < Infra::Models::ApplicationRecord
      has_many :service_order_items, as: :item

      validates :name, presence: true
      validates :base_price, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end

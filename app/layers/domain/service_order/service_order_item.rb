module Domain
  module ServiceOrder
    class ServiceOrderItem < Infra::Models::ApplicationRecord
      belongs_to :service_order, class_name: "Domain::ServiceOrder::ServiceOrder"
      belongs_to :item, polymorphic: true

      validates :quantity, numericality: { only_integer: true, greater_than: 0 }

      scope :products, -> { where(item_kind: "product") }
      scope :services, -> { where(item_kind: "service") }

      def item_price
        quantity * item.base_price
      end
    end
  end
end

module Domain
  module ServiceOrder
    class ServiceOrderItem < Infra::Models::ApplicationRecord
      ITEM_KINDS = {
        product: "product",
        service: "service"
      }.freeze

      belongs_to :service_order, class_name: "Domain::ServiceOrder::ServiceOrder"

      validates :quantity, numericality: { only_integer: true, greater_than: 0 }

      enum :item_kind, {
        product: "product",
        service: "service"
      }

      scope :products, -> { where(item_kind: "product") }
      scope :services, -> { where(item_kind: "service") }

      def item_price
        quantity * item.base_price
      end
    end
  end
end

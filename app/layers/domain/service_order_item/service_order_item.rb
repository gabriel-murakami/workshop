module Domain
  module ServiceOrderItem
    class ServiceOrderItem < Infra::Models::ApplicationRecord
      belongs_to :service_order, class_name: "Domain::ServiceOrder::ServiceOrder"
      belongs_to :item, polymorphic: true

      validates :quantity, numericality: { only_integer: true, greater_than: 0 }

      scope :auto_parts, -> { where(item_type: "Domain::ServiceOrderItem::AutoPart") }
      scope :services, -> { where(item_type: "Domain::ServiceOrderItem::Service") }

      def item_price
        quantity * item.base_price
      end
    end
  end
end

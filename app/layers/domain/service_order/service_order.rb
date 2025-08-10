module Domain
  module ServiceOrder
    class ServiceOrder < Infra::Models::ApplicationRecord
      belongs_to :customer, class_name: "Domain::Customer::Customer"
      belongs_to :vehicle, class_name: "Domain::Customer::Vehicle"

      has_one :budget, dependent: :destroy

      has_many :service_order_items, class_name: "Domain::ServiceOrderItem::ServiceOrderItem", dependent: :destroy

      has_many :services,
        class_name: "Domain::ServiceOrderItem::Service",
        through: :service_order_items, source: :item, source_type: "Domain::ServiceOrderItem::Service"
      has_many :auto_parts,
        class_name: "Domain::ServiceOrderItem::AutoPart",
        through: :service_order_items, source: :item, source_type: "Domain::ServiceOrderItem::AutoPart"

      enum status: {
        open: "open",
        received: "received",
        diagnosing: "diagnosing",
        awaiting_approval: "awaiting_approval",
        in_progress: "in_progress",
        finished: "finished",
        delivered: "delivered",
        cancelled: "cancelled"
      }

      validates :status, presence: true

      def add_services(services)
        services.each do |service|
          service_order_items.create(item: service, quantity: 1)
        end
      end

      def add_auto_parts(auto_parts)
        auto_parts.each do |auto_part|
          service_order_items.create(
            item: auto_part[:item],
            quantity: auto_part[:quantity]
          )
        end
      end
    end
  end
end

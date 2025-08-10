module Domain
  module ServiceOrder
    class ServiceOrder < Infra::Models::ApplicationRecord
      belongs_to :customer, class_name: "Domain::Customer::Customer"
      belongs_to :vehicle, class_name: "Domain::Customer::Vehicle"

      has_one :budget, dependent: :destroy

      has_many :service_order_items, class_name: "Domain::ServiceOrderItem::ServiceOrderItem", dependent: :destroy

      has_many :services, class_name: "Domain::ServiceOrderItem::Service", through: :service_order_items, source: :item, source_type: "Service"
      has_many :auto_parts, class_name: "Domain::ServiceOrderItem::AutoPart", through: :service_order_items, source: :item, source_type: "Part"

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
    end
  end
end

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
        received: "received",
        diagnosis: "diagnosis",
        waiting_approval: "waiting_approval",
        approved: "approved",
        in_progress: "in_progress",
        finished: "finished",
        delivered: "delivered",
        cancelled: "cancelled"
      }

      validates :status, presence: true

      def add_services(services)
        services.each do |service|
          if self.service_order_items.services.any? { |soi| soi.item_id == service.id }
            raise Exceptions::ServiceOrderException.new("Service #{service.code} already added")
          end

          service_order_items.create(
            item: service,
            quantity: 1,
            total_value: service.base_price
          )
        end
      end

      def add_auto_parts(auto_parts)
        auto_parts.each do |auto_part|
          if self.service_order_items.auto_parts.any? { |soi| soi.item_id == auto_part[:item].id }
            raise Exceptions::ServiceOrderException.new("Auto part #{auto_part[:item].sku} already added")
          end

          service_order_items.create(
            item: auto_part[:item],
            quantity: auto_part[:quantity],
            total_value: auto_part[:item].base_price * auto_part[:quantity]
          )
        end
      end
    end
  end
end

module Domain
  module ServiceOrder
    class ServiceOrder < Infra::Models::ApplicationRecord
      belongs_to :customer, class_name: "Domain::Customer::Customer", required: true
      belongs_to :vehicle, class_name: "Domain::Customer::Vehicle", required: true

      after_update_commit :send_status_update_email, if: :saved_change_to_status?

      has_one :budget, dependent: :destroy
      has_many :service_order_items, class_name: "Domain::ServiceOrder::ServiceOrderItem", dependent: :destroy

      enum :status, {
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
          if self.service_order_items.services.any? { |soi| soi.item_id == service.dig(:item, :id) }
            raise Exceptions::ServiceOrderException.new("Service #{service.dig(:item, :code)} already added")
          end

          service_order_items.create(
            item_id: service.dig(:item, :id),
            item_kind: ServiceOrderItem::ITEM_KINDS[:service],
            quantity: 1,
            total_value: service.dig(:item, :base_price)
          )
        end
      end

      def add_products(products)
        products.each do |product|
          if self.service_order_items.products.any? { |soi| soi.item_id == product.dig(:item, :id) }
            raise Exceptions::ServiceOrderException.new("Auto part #{product.dig(:item, :sku)} already added")
          end

          service_order_items.create(
            item_id: product.dig(:item, :id),
            item_kind: ServiceOrderItem::ITEM_KINDS[:product],
            quantity: product[:quantity],
            total_value: product.dig(:item, :base_price) * product[:quantity]
          )
        end
      end

      private

      def send_status_update_email
        ServiceOrderMailer.status_updated(self).deliver_later
      end
    end
  end
end

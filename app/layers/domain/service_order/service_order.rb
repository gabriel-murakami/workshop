module Domain
  module ServiceOrder
    class ServiceOrder < Infra::Models::ApplicationRecord
      belongs_to :customer, class_name: "Domain::Customer::Customer", required: true
      belongs_to :vehicle, class_name: "Domain::Customer::Vehicle", required: true

      after_update_commit :send_status_update_email, if: :saved_change_to_status?

      has_one :budget, dependent: :destroy

      has_many :service_order_items, class_name: "Domain::ServiceOrderItem::ServiceOrderItem", dependent: :destroy

      has_many :services,
        class_name: "Domain::ServiceOrderItem::Service",
        through: :service_order_items, source: :item, source_type: "Domain::ServiceOrderItem::Service"
      has_many :products,
        class_name: "Domain::ServiceOrderItem::Product",
        through: :service_order_items, source: :item, source_type: "Domain::ServiceOrderItem::Product"

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

      def add_products(products)
        products.each do |product|
          if self.service_order_items.products.any? { |soi| soi.item_id == product[:item].id }
            raise Exceptions::ServiceOrderException.new("Auto part #{product[:item].sku} already added")
          end

          service_order_items.create(
            item: product[:item],
            quantity: product[:quantity],
            total_value: product[:item].base_price * product[:quantity]
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

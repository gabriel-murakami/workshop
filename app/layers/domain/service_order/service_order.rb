module Domain
  module ServiceOrder
    class ServiceOrder < Infra::Models::ApplicationRecord
      # belongs_to :customer, class_name: "Domain::Customer::Customer", required: true
      # belongs_to :vehicle, class_name: "Domain::Customer::Vehicle", required: true

      after_update_commit :send_payment_pending_email, if: :saved_change_to_status?

      has_one :budget, dependent: :destroy
      has_many :service_order_items, class_name: "Domain::ServiceOrder::ServiceOrderItem", dependent: :destroy

      enum :status, {
        received: "received",
        diagnosis: "diagnosis",
        waiting_approval: "waiting_approval",
        approved: "approved",
        pending_payment: "pending_payment",
        payment_approved: "payment_approved",
        in_progress: "in_progress",
        finished: "finished",
        delivered: "delivered",
        cancelled: "cancelled"
      }

      validates :status, presence: true

      def services
        service_order_items.services
      end

      def products
        service_order_items.products
      end

      def add_services(services_to_add)
        services_to_add.each do |service|
          if self.service_order_items.services.any? { |soi| soi.item_id == service[:id] }
            raise ::Exceptions::ServiceOrderException.new("Service #{service[:code]} already added")
          end

          service_order_items.create(
            item_id: service[:id],
            item_name: service[:name],
            item_code: service[:code],
            item_kind: ServiceOrderItem::ITEM_KINDS[:service],
            quantity: 1,
            total_value: service[:base_price].to_f
          )
        end
      end

      def add_products(products_to_add)
        products_to_add.each do |product|
          if self.service_order_items.products.any? { |soi| soi.item_id == product[:item][:id] }
            raise Exceptions::ServiceOrderException.new("Auto part #{product[:item][:sku]} already added")
          end

          service_order_items.create(
            item_id: product[:item][:id],
            item_name: product[:item][:name],
            item_code: product[:item][:sku],
            item_kind: ServiceOrderItem::ITEM_KINDS[:product],
            quantity: product[:quantity],
            total_value: product[:item][:base_price].to_f * product[:quantity]
          )
        end
      end

      private

      def send_payment_pending_email
        if status == "pending_payment"
          ServiceOrderMailer.pending_payment(self).deliver_later
        else
          ServiceOrderMailer.status_updated(self).deliver_later
        end
      end
    end
  end
end

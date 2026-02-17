require "bunny"
require "json"

module Infra
  module Workers
    class OrderApprovedWorker
      include Sneakers::Worker

      from_queue "order.approved",
                exchange: "app.exchange",
                exchange_type: :direct,
                durable: true,
                ack: true

      def work(raw_message)
        payload = JSON.parse(raw_message, symbolize_names: true)

        Rails.logger.info("ORDER APPROVED")
        Rails.logger.info(payload)

        Application::ServiceOrder::ServiceOrderApplication.new.send_to_pending_payment(payload[:service_order_id])

        ack!
      rescue => e
        Rails.logger.error(e.message)
        reject!
      end
    end
  end
end

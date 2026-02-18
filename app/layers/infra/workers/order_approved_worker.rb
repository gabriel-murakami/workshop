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
        event = JSON.parse(raw_message, symbolize_names: true)

        result = Infra::Clients::MercadopagoClient.new(
          service_order_id: event[:service_order_id]
        ).create_order(event[:amount])

        Domain::ServiceOrder::Payment.create!(
          service_order_id: event[:service_order_id],
          amount: event[:amount],
          status: "pending",
          external_id: result["id"],
          provider_payload: result.slice(
            "init_point", "notification_url", "operation_type", "items"
          )
        )

        Application::ServiceOrder::ServiceOrderApplication.new.send_to_pending_payment(event[:service_order_id])

        ack!
      rescue => e
        Rails.logger.error(e.message)
        reject!
      end
    end
  end
end

require "bunny"
require "json"

module Infra
  module Workers
    class PaymentReceivedWorker
      include Sneakers::Worker

      from_queue "payment.webhook.received",
          exchange: "app.exchange",
          exchange_type: :direct,
          durable: true,
          ack: true

      def work(raw_message)
        event = JSON.parse(raw_message, symbolize_names: true)

        external_payment = Infra::Clients::MercadopagoClient.new.get_payment(event[:external_payment_id])
        payment = Domain::ServiceOrder::Payment.find_by(service_order_id: external_payment["external_reference"])
        service_order = Application::ServiceOrder::ServiceOrderApplication.new.find_by_id(payment.service_order_id)

        payment.update(status: external_payment["status"])
        service_order.update(status: "payment_approved")

        ack!
      end
    end
  end
end

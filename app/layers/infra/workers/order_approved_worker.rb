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
        payload = JSON.parse(raw_message)

        Rails.logger("ORDER APPROVED")
        Rails.logger(payload)

        ack!
      rescue => e
        Rails.logger.error(e.message)
        reject!
      end
    end
  end
end

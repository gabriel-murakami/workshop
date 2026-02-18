require "bunny"
require "json"

module EventBus
  class Publisher
    def self.publish(routing_key, payload)
      connection = Bunny.new(
        host: ENV["RABBITMQ_HOST"],
        user: ENV["RABBITMQ_USER"],
        password: ENV["RABBITMQ_PASSWORD"]
      )

      connection.start
      channel = connection.create_channel

      exchange = channel.direct("app.exchange", durable: true)

      exchange.publish(
        payload.to_json,
        routing_key: routing_key,
        persistent: true
      )

      Rails.logger.tagged("EventBus::Publisher") do
        Rails.logger.info(payload.merge(routing_key: routing_key))
      end

      connection.close
    end
  end
end

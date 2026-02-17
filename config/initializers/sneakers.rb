Sneakers.configure(
  amqp: "amqp://#{ENV['RABBITMQ_USER']}:#{ENV['RABBITMQ_PASSWORD']}@#{ENV['RABBITMQ_HOST']}:5672",
  exchange: "app.exchange",
  exchange_type: :direct,
  durable: true,
  workers: 1
)

Sneakers.logger.level = Logger::INFO

Sneakers.configure(
  amqp: "amqp://#{ENV['RABBITMQ_USER']}:#{ENV['RABBITMQ_PASSWORD']}@#{ENV['RABBITMQ_HOST']}:5672",
  workers: 2,
  threads: 2,
  durable: true,
  ack: true,
  heartbeat: 30
)

Sneakers.logger.level = Logger::INFO

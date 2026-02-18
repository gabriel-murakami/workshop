require "securerandom"

Domain::ServiceOrder::Budget.delete_all
Domain::ServiceOrder::ServiceOrderItem.delete_all
Domain::ServiceOrder::ServiceOrder.delete_all
Domain::ServiceOrder::Metric.delete_all
Domain::ServiceOrder::User.delete_all
Domain::Catalog::Service.delete_all
Domain::Catalog::Product.delete_all
Domain::ServiceOrder::Payment.delete_all

Domain::ServiceOrder::User.create!(
  name: "Administrador",
  email: "admin@admin.com",
  password: "password123",
  password_confirmation: "password123",
  document_number: "54367578046"
)

customers = 4.times.map { SecureRandom.uuid }
vehicles  = 5.times.map { SecureRandom.uuid }

services = [
  { code: "SVC001", name: "Troca de Óleo", description: "Substituir óleo do motor e filtro", base_price: 120.00 },
  { code: "SVC002", name: "Inspeção de Freios", description: "Verificar pastilhas e discos de freio", base_price: 80.00 },
  { code: "SVC003", name: "Diagnóstico de Motor", description: "Diagnóstico completo do sistema do motor", base_price: 150.00 }
].map { |attrs| Domain::Catalog::Service.create!(attrs) }

products = [
  { sku: "AP001", name: "Filtro de Óleo", description: "Filtro de óleo de alta qualidade", stock_quantity: 50, base_price: 30.99 },
  { sku: "AP002", name: "Pastilhas de Freio", description: "Jogo de pastilhas de freio dianteiras", stock_quantity: 20, base_price: 92.89 },
  { sku: "AP003", name: "Vela de Ignição", description: "Vela de ignição padrão", stock_quantity: 100, base_price: 15.54 },
  { sku: "AP004", name: "Óleo de Motor 5W30", description: "Garrafa de óleo de motor 5W30", stock_quantity: 250, base_price: 65.89 }
].map { |attrs| Domain::Catalog::Product.create!(attrs) }

def add_item(order:, item:, kind:, quantity:)
  order.service_order_items.create!(
    item_kind: kind,
    item_id: item.id,
    item_name: item.name,
    item_code: kind == "service" ? item.code : item.sku,
    quantity: quantity,
    total_value: item.base_price * quantity
  )
end

os1 = Domain::ServiceOrder::ServiceOrder.create!(
  customer_id: customers[0],
  vehicle_id: vehicles[0],
  status: "waiting_approval",
  description: "Cliente relatou barulho estranho vindo do motor."
)

add_item(order: os1, item: services[2], kind: "service", quantity: 1)
add_item(order: os1, item: products[2], kind: "product", quantity: 4)

Domain::ServiceOrder::Budget.create!(
  service_order: os1,
  date: Date.current - 4.days,
  total_value: os1.service_order_items.sum(:total_value),
  status: "pending"
)

os2 = Domain::ServiceOrder::ServiceOrder.create!(
  customer_id: customers[1],
  vehicle_id: vehicles[2],
  status: "in_progress",
  description: "Revisão de freios e troca de óleo de rotina.",
  service_started_at: Time.current
)

add_item(order: os2, item: services[0], kind: "service", quantity: 1)
add_item(order: os2, item: services[1], kind: "service", quantity: 1)
add_item(order: os2, item: products[0], kind: "product", quantity: 1)
add_item(order: os2, item: products[1], kind: "product", quantity: 1)

Domain::ServiceOrder::Budget.create!(
  service_order: os2,
  date: Date.current - 1.day,
  total_value: os2.service_order_items.sum(:total_value),
  status: "approved"
)

os3 = Domain::ServiceOrder::ServiceOrder.create!(
  customer_id: customers[3],
  vehicle_id: vehicles[4],
  status: "diagnosis",
  description: "Diagnóstico de barulho no motor em andamento."
)

os4 = Domain::ServiceOrder::ServiceOrder.create!(
  customer_id: customers[2],
  vehicle_id: vehicles[3],
  status: "in_progress",
  description: "Serviço em andamento há 15 minutos.",
  service_started_at: 15.minutes.ago
)

add_item(order: os4, item: services[1], kind: "service", quantity: 1)
add_item(order: os4, item: products[3], kind: "product", quantity: 2)

Domain::ServiceOrder::Budget.create!(
  service_order: os4,
  date: Date.current,
  total_value: os4.service_order_items.sum(:total_value),
  status: "approved"
)


Domain::ServiceOrder::Metric.create!(
  service_order_count: Domain::ServiceOrder::ServiceOrder.count,
  average_time: 0.0
)

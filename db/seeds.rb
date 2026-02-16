Domain::ServiceOrder::Budget.delete_all
Domain::ServiceOrder::ServiceOrderItem.delete_all
Domain::ServiceOrder::ServiceOrder.delete_all
Domain::ServiceOrder::Metric.delete_all
Domain::ServiceOrder::User.delete_all
Domain::Customer::Vehicle.delete_all
Domain::Customer::Customer.delete_all
Domain::Catalog::Service.delete_all
Domain::Catalog::Product.delete_all

Domain::ServiceOrder::User.create!(
  name: "Administrador",
  email: "admin@admin.com",
  password: "password123",
  password_confirmation: "password123",
  document_number: "54367578046"
)

clientes = [
  { name: "Luke Skywalker", document_number: "38830424048", email: "luke@jedi.com", phone: "+55 (11) 91234-5678" },
  { name: "Leia Organa", document_number: "49859924023", email: "leia@rebellion.org", phone: "+55 (21) 99876-5432" },
  { name: "Han Solo", document_number: "93715993081", email: "han@falcon.space", phone: "+55 (31) 98765-4321" },
  { name: "Darth Vader", document_number: "10457656000", email: "vader@empire.gov", phone: "+55 (41) 99999-0000" }
].map { |attrs| Domain::Customer::Customer.create!(attrs) }

veiculos = []
veiculos << Domain::Customer::Vehicle.create!(customer: clientes[0], license_plate: "ABC1234", brand: "Toyota", model: "Corolla", year: 2020)
veiculos << Domain::Customer::Vehicle.create!(customer: clientes[0], license_plate: "DEF5678", brand: "Ford", model: "Mustang", year: 2018)
veiculos << Domain::Customer::Vehicle.create!(customer: clientes[1], license_plate: "GHI9012", brand: "Honda", model: "Civic", year: 2019)
veiculos << Domain::Customer::Vehicle.create!(customer: clientes[2], license_plate: "JKL3456", brand: "Chevrolet", model: "Camaro", year: 2021)
veiculos << Domain::Customer::Vehicle.create!(customer: clientes[3], license_plate: "EMP0001", brand: "Imperial", model: "Destroyer", year: 2022)

servicos = [
  { code: "SVC001", name: "Troca de Óleo", description: "Substituir óleo do motor e filtro", base_price: 120.00 },
  { code: "SVC002", name: "Inspeção de Freios", description: "Verificar pastilhas e discos de freio", base_price: 80.00 },
  { code: "SVC003", name: "Diagnóstico de Motor", description: "Diagnóstico completo do sistema do motor", base_price: 150.00 }
].map { |attrs| Domain::Catalog::Service.create!(attrs) }

produtos = [
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
    unit_price: item.base_price,
    total_value: item.base_price * quantity
  )
end

os1 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[0],
  vehicle: veiculos[0],
  status: "waiting_approval",
  description: "Cliente relatou barulho estranho vindo do motor."
)

add_item(order: os1, item: servicos[2], kind: "service", quantity: 1)
add_item(order: os1, item: produtos[2], kind: "product", quantity: 4)

Domain::ServiceOrder::Budget.create!(
  service_order: os1,
  date: Date.current - 4.days,
  total_value: os1.service_order_items.sum(:total_value),
  status: "pending"
)

os2 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[1],
  vehicle: veiculos[2],
  status: "in_progress",
  description: "Revisão de freios e troca de óleo de rotina.",
  service_started_at: Time.current
)

add_item(order: os2, item: servicos[0], kind: "service", quantity: 1)
add_item(order: os2, item: servicos[1], kind: "service", quantity: 1)
add_item(order: os2, item: produtos[0], kind: "product", quantity: 1)
add_item(order: os2, item: produtos[1], kind: "product", quantity: 1)

Domain::ServiceOrder::Budget.create!(
  service_order: os2,
  date: Date.current - 1.day,
  total_value: os2.service_order_items.sum(:total_value),
  status: "approved"
)

os3 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[3],
  vehicle: veiculos[4],
  status: "diagnosis",
  description: "Diagnóstico de barulho no motor em andamento."
)

os4 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[2],
  vehicle: veiculos[3],
  status: "in_progress",
  description: "Serviço em andamento há 15 minutos.",
  service_started_at: 15.minutes.ago
)

add_item(order: os4, item: servicos[1], kind: "service", quantity: 1)
add_item(order: os4, item: produtos[3], kind: "product", quantity: 2)

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

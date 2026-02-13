Domain::ServiceOrder::Budget.delete_all
Domain::ServiceOrder::ServiceOrderItem.delete_all
Domain::ServiceOrder::ServiceOrder.delete_all
Domain::ServiceOrder::User.delete_all
Domain::Customer::Vehicle.delete_all
Domain::Customer::Customer.delete_all
Domain::Catalog::Service.delete_all
Domain::Catalog::Product.delete_all
Domain::ServiceOrder::Metric.delete_all

puts "Criando usuário administrador"
Domain::ServiceOrder::User.create!(
  name: "Administrador",
  email: 'admin@admin.com',
  password: 'password123',
  password_confirmation: 'password123',
  document_number: '54367578046'
)

puts "Criando clientes..."
clientes = [
  { name: "Luke Skywalker", document_number: "38830424048", email: "gabriel.m.alves42@gmail.com", phone: "+55 (11) 91234-5678" },
  { name: "Leia Organa", document_number: "49859924023", email: "leia@rebellion.org", phone: "+55 (21) 99876-5432" },
  { name: "Han Solo", document_number: "93715993081", email: "han@falcon.space", phone: "+55 (31) 98765-4321" },
  { name: "Darth Vader", document_number: "10457656000", email: "vader@empire.gov", phone: "+55 (41) 99999-0000" }
].map { |attrs| Domain::Customer::Customer.create!(attrs) }

puts "Criando veículos..."
veiculos = [
  { customer: clientes[0], license_plate: "ABC1234", brand: "Toyota", model: "Corolla", year: 2020 },
  { customer: clientes[0], license_plate: "DEF5678", brand: "Ford", model: "Mustang", year: 2018 },
  { customer: clientes[1], license_plate: "GHI9012", brand: "Honda", model: "Civic", year: 2019 },
  { customer: clientes[2], license_plate: "JKL3456", brand: "Chevrolet", model: "Camaro", year: 2021 }
].map { |attrs| Domain::Customer::Vehicle.create!(attrs) }

puts "Criando serviços..."
servicos = [
  { code: "SVC001", name: "Troca de Óleo", description: "Substituir óleo do motor e filtro", base_price: 120.00 },
  { code: "SVC002", name: "Inspeção de Freios", description: "Verificar pastilhas e discos de freio", base_price: 80.00 },
  { code: "SVC003", name: "Diagnóstico de Motor", description: "Diagnóstico completo do sistema do motor", base_price: 150.00 }
].map { |attrs| Domain::Catalog::Service.create!(attrs) }

puts "Criando produtos..."
produtos = [
  { sku: "AP001", name: "Filtro de Óleo", description: "Filtro de óleo de alta qualidade", stock_quantity: 50, base_price: 30.99 },
  { sku: "AP002", name: "Pastilhas de Freio", description: "Jogo de pastilhas de freio dianteiras", stock_quantity: 20, base_price: 92.89 },
  { sku: "AP003", name: "Vela de Ignição", description: "Vela de ignição padrão", stock_quantity: 100, base_price: 15.54 },
  { sku: "AP004", name: "Óleo de Motor 5W30", description: "Garrafa de óleo de motor 5W30", stock_quantity: 250, base_price: 65.89 }
].map { |attrs| Domain::Catalog::Product.create!(attrs) }

puts "Criando ordens de serviço com itens e orçamentos..."

os1 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[0],
  vehicle: veiculos[0],
  status: :waiting_approval,
  description: "Cliente relatou barulho estranho vindo do motor."
)

os1.service_order_items.create!(
  item: servicos[2],
  quantity: 1,
  total_value: servicos[2].base_price * 1
)

os1.service_order_items.create!(
  item: produtos[2],
  quantity: 4,
  total_value: produtos[2].base_price * 4
)

Domain::ServiceOrder::Budget.create!(
  service_order: os1,
  date: Date.today - 4.days,
  total_value: (servicos[2].base_price * 1 + produtos[2].base_price * 4),
  status: :pending
)

os2 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[1],
  vehicle: veiculos[2],
  status: :in_progress,
  description: "Revisão de freios e troca de óleo de rotina.",
  service_started_at: Time.zone.now
)

os2.service_order_items.create!(
  item: servicos[0],
  quantity: 1,
  total_value: servicos[0].base_price * 1
)

os2.service_order_items.create!(
  item: servicos[1],
  quantity: 1,
  total_value: servicos[1].base_price * 1
)

os2.service_order_items.create!(
  item: produtos[0],
  quantity: 1,
  total_value: produtos[0].base_price * 1
)

os2.service_order_items.create!(
  item: produtos[1],
  quantity: 1,
  total_value: produtos[1].base_price * 1
)

Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[3],
  vehicle: veiculos[3],
  status: :diagnosis,
  description: "Diagnóstico de barulho no motor em andamento."
)

os4 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: clientes[2],
  vehicle: veiculos[2],
  status: :in_progress,
  description: "Serviço em andamento há 15 minutos.",
  service_started_at: 15.minutes.ago
)

os4.service_order_items.create!(
  item: servicos[1],
  quantity: 1,
  total_value: servicos[1].base_price * 1
)

os4.service_order_items.create!(
  item: produtos[3],
  quantity: 2,
  total_value: produtos[3].base_price * 2
)

Domain::ServiceOrder::Budget.create!(
  service_order: os2,
  date: Date.today - 1.day,
  total_value: (
    servicos[0].base_price * 1 +
    servicos[1].base_price * 1 +
    produtos[0].base_price * 1 +
    produtos[1].base_price * 1
  ),
  status: :approved
)

Domain::ServiceOrder::Budget.create!(
  service_order: os4,
  date: Date.today,
  total_value: (servicos[1].base_price * 1 + produtos[3].base_price * 2),
  status: :approved
)

puts "Seed criado com sucesso"

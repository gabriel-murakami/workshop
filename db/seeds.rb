Domain::ServiceOrder::Budget.delete_all
Domain::ServiceOrderItem::ServiceOrderItem.delete_all
Domain::ServiceOrder::ServiceOrder.delete_all
Domain::ServiceOrder::User.delete_all
Domain::Customer::Vehicle.delete_all
Domain::Customer::Customer.delete_all
Domain::ServiceOrderItem::Service.delete_all
Domain::ServiceOrderItem::Product.delete_all
Domain::ServiceOrder::Metric.delete_all

puts "Creating admin user"
Domain::ServiceOrder::User.create!(
  name: "Admin",
  email: 'admin@admin.com',
  password: 'password123',
  password_confirmation: 'password123'
)

puts "Creating customers..."
customers = [
  { name: "Luke Skywalker", document_number: "388.304.240-48", email: "luke@rebellion.org", phone: "+55 (11) 91234-5678" },
  { name: "Leia Organa", document_number: "498.599.240-23", email: "leia@rebellion.org", phone: "+55 (21) 99876-5432" },
  { name: "Han Solo", document_number: "937.159.930-81", email: "han@falcon.space", phone: "+55 (31) 98765-4321" },
  { name: "Darth Vader", document_number: "104.576.560-00", email: "vader@empire.gov", phone: "+55 (41) 99999-0000" }
].map { |attrs| Domain::Customer::Customer.create!(attrs) }

puts "Creating vehicles..."
vehicles = [
  { customer: customers[0], license_plate: "ABC1234", brand: "Toyota", model: "Corolla", year: 2020 },
  { customer: customers[0], license_plate: "DEF5678", brand: "Ford", model: "Mustang", year: 2018 },
  { customer: customers[1], license_plate: "GHI9012", brand: "Honda", model: "Civic", year: 2019 },
  { customer: customers[2], license_plate: "JKL3456", brand: "Chevrolet", model: "Camaro", year: 2021 }
].map { |attrs| Domain::Customer::Vehicle.create!(attrs) }

puts "Creating services..."
services = [
  { code: "SVC001", name: "Oil Change", description: "Replace engine oil and filter", base_price: 120.00 },
  { code: "SVC002", name: "Brake Inspection", description: "Check brake pads and discs", base_price: 80.00 },
  { code: "SVC003", name: "Engine Diagnostics", description: "Full engine system diagnostics", base_price: 150.00 }
].map { |attrs| Domain::ServiceOrderItem::Service.create!(attrs) }

puts "Creating products..."
products = [
  { sku: "AP001", name: "Oil Filter", description: "High quality oil filter", stock_quantity: 50, base_price: 30.99 },
  { sku: "AP002", name: "Brake Pads", description: "Set of front brake pads", stock_quantity: 20, base_price: 92.89 },
  { sku: "AP003", name: "Spark Plug", description: "Standard spark plug", stock_quantity: 100, base_price: 15.54 },
  { sku: "AP004", name: "Engine Oil Bottle", description: "5W30 Engine Oil Bottle", stock_quantity: 250, base_price: 65.89 }
].map { |attrs| Domain::ServiceOrderItem::Product.create!(attrs) }

puts "Creating service orders with items and budgets..."

service_order1 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[0],
  vehicle: vehicles[0],
  status: :waiting_approval,
  description: "Customer reported strange noise from engine."
)

service_order1.service_order_items.create!(
  item: services[2],
  quantity: 1,
  total_value: services[2].base_price * 1
)

service_order1.service_order_items.create!(
  item: products[2],
  quantity: 4,
  total_value: products[2].base_price * 4
)

Domain::ServiceOrder::Budget.create!(
  service_order: service_order1,
  date: Date.today - 4.days,
  total_value: (services[2].base_price * 1 + products[2].base_price * 4),
  status: :pending
)

service_order2 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[1],
  vehicle: vehicles[2],
  status: :in_progress,
  description: "Routine brake check and oil change.",
  service_started_at: Time.zone.now
)

service_order2.service_order_items.create!(
  item: services[0],
  quantity: 1,
  total_value: services[0].base_price * 1
)

service_order2.service_order_items.create!(
  item: services[1],
  quantity: 1,
  total_value: services[1].base_price * 1
)

service_order2.service_order_items.create!(
  item: products[0],
  quantity: 1,
  total_value: products[0].base_price * 1
)

service_order2.service_order_items.create!(
  item: products[1],
  quantity: 1,
  total_value: products[1].base_price * 1
)

service_order3 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[3],
  vehicle: vehicles[3],
  status: :diagnosis,
  description: "Engine noise diagnosis in progress."
)

service_order3.service_order_items.create!(
  item: services[2],
  quantity: 1,
  total_value: services[2].base_price * 1
)

service_order3.service_order_items.create!(
  item: products[2],
  quantity: 2,
  total_value: products[2].base_price * 2
)

Domain::ServiceOrder::Budget.create!(
  service_order: service_order2,
  date: Date.today - 1.day,
  total_value: (
    services[0].base_price * 1 +
    services[1].base_price * 1 +
    products[0].base_price * 1 +
    products[1].base_price * 1
  ),
  status: :approved
)

Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[0],
  vehicle: vehicles[1],
  description: "Strange noises."
)

Domain::ServiceOrder::Metric.create!(
  average_time: 56.9,
  service_order_count: 14
)

puts "Seed created"

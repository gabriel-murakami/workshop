Domain::ServiceOrder::Budget.delete_all
Domain::ServiceOrderItem::ServiceOrderItem.delete_all
Domain::ServiceOrder::ServiceOrder.delete_all
Domain::Customer::Vehicle.delete_all
Domain::Customer::Customer.delete_all
Domain::ServiceOrderItem::Service.delete_all
Domain::ServiceOrderItem::AutoPart.delete_all

puts "Creating customers..."
customers = [
  { name: "Luke Skywalker", document_number: "12345678901", email: "luke@rebellion.org", phone: "555-0001" },
  { name: "Leia Organa", document_number: "10987654321", email: "leia@rebellion.org", phone: "555-0002" },
  { name: "Han Solo", document_number: "19283746500", email: "han@falcon.space", phone: "555-0003" },
  { name: "Darth Vader", document_number: "56473829100", email: "vader@empire.gov", phone: "555-0004" }
].map { |attrs| Domain::Customer::Customer.create!(attrs) }

puts "Creating vehicles..."
vehicles = [
  { customer: customers[0], license_plate: "ABC-1234", brand: "Toyota", model: "Corolla", year: 2020 },
  { customer: customers[0], license_plate: "DEF-5678", brand: "Ford", model: "Mustang", year: 2018 },
  { customer: customers[1], license_plate: "GHI-9012", brand: "Honda", model: "Civic", year: 2019 },
  { customer: customers[2], license_plate: "JKL-3456", brand: "Chevrolet", model: "Camaro", year: 2021 }
].map { |attrs| Domain::Customer::Vehicle.create!(attrs) }

puts "Creating services..."
services = [
  { name: "Oil Change", description: "Replace engine oil and filter", base_price: 120.00 },
  { name: "Brake Inspection", description: "Check brake pads and discs", base_price: 80.00 },
  { name: "Engine Diagnostics", description: "Full engine system diagnostics", base_price: 150.00 }
].map { |attrs| Domain::ServiceOrderItem::Service.create!(attrs) }

puts "Creating auto parts..."
auto_parts = [
  { name: "Oil Filter", description: "High quality oil filter", stock_quantity: 50, base_price: 30.00 },
  { name: "Brake Pads", description: "Set of front brake pads", stock_quantity: 20, base_price: 90.00 },
  { name: "Spark Plug", description: "Standard spark plug", stock_quantity: 100, base_price: 15.00 }
].map { |attrs| Domain::ServiceOrderItem::AutoPart.create!(attrs) }

puts "Creating service orders with items and budgets..."

service_order1 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[0],
  vehicle: vehicles[0],
  opening_date: Date.today - 5.days,
  status: :received,
  description: "Customer reported strange noise from engine."
)

# Add service items
service_order1.service_order_items.create!(item: services[2], quantity: 1)
service_order1.service_order_items.create!(item: auto_parts[2], quantity: 4)

# Add budget
Domain::ServiceOrder::Budget.create!(
  service_order: service_order1,
  date: Date.today - 4.days,
  total_value: (services[2].base_price + auto_parts[2].base_price * 4),
  status: :pending
)

service_order2 = Domain::ServiceOrder::ServiceOrder.create!(
  customer: customers[1],
  vehicle: vehicles[2],
  opening_date: Date.today - 2.days,
  status: :in_progress,
  description: "Routine brake check and oil change."
)

service_order2.service_order_items.create!(item: services[0], quantity: 1)
service_order2.service_order_items.create!(item: services[1], quantity: 1)
service_order2.service_order_items.create!(item: auto_parts[0], quantity: 1)
service_order2.service_order_items.create!(item: auto_parts[1], quantity: 1)

Domain::ServiceOrder::Budget.create!(
  service_order: service_order2,
  date: Date.today - 1.day,
  total_value: (services[0].base_price + services[1].base_price + auto_parts[0].base_price + auto_parts[1].base_price),
  status: :approved
)

puts "Seed created"

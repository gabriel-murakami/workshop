class Domain::Customer::VehicleSerializer < ActiveModel::Serializer
  attributes :id, :license_plate, :brand, :model, :year, :created_at, :updated_at, :customer_id

  # belongs_to :customer_id
  # has_many :service_orders_ids
  attribute(:service_orders_ids) { object.service_orders.map(&:id) }
end

class Domain::ServiceOrder::ServiceOrderSerializer < ActiveModel::Serializer
  attributes :id, :service_started_at, :service_finished_at, :status, :description,
    :created_at, :updated_at, :customer_id, :vehicle_id
  attribute(:abc) { "wodjklfhjsdiokf" }

  has_one :budget
  has_many :service_order_items
end

module Serializers
  class Domain::ServiceOrder::ServiceOrderSerializer < ActiveModel::Serializer
    attributes :id, :service_started_at, :service_finished_at, :status, :description,
      :created_at, :updated_at, :customer_id, :vehicle_id

    has_one :budget
    has_many :service_order_items, serializer: Serializers::Domain::ServiceOrderItem::ServiceOrderItemSerializer
  end
end

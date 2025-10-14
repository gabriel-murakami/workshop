module Serializers
  class Domain::Customer::CustomerSerializer < ActiveModel::Serializer
    attributes :id, :name, :document_number, :email, :phone, :created_at, :updated_at

    attribute(:vehicles_ids) { object.vehicles.map(&:id) }
    attribute(:service_orders_ids) { object.service_orders.map(&:id) }
  end
end

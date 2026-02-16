module Serializers
  class Domain::ServiceOrder::ServiceOrderItemSerializer < ActiveModel::Serializer
    attributes :id, :quantity, :total_value, :item_kind, :item_id, :created_at, :updated_at
  end
end

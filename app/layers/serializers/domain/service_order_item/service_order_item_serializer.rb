module Serializers
  class Domain::ServiceOrderItem::ServiceOrderItemSerializer < ActiveModel::Serializer
    attributes :id, :quantity, :total_value, :item_type, :item_id, :created_at, :updated_at
  end
end

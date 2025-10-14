module Serializers
  class Domain::ServiceOrderItem::ProductSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :stock_quantity, :base_price, :sku, :created_at, :updated_at
  end
end

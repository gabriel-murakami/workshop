module Serializers
  class Domain::Catalog::ServiceSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :base_price, :code, :created_at, :updated_at
  end
end

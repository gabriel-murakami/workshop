module Serializers
  class Domain::ServiceOrder::MetricSerializer < ActiveModel::Serializer
    attributes :id, :service_order_count, :created_at, :updated_at

    attribute(:average_time) { object.average_time.to_f.round(2) }
  end
end

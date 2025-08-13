class Domain::ServiceOrder::CurrentStatusSerializer < ActiveModel::Serializer
  attributes :id, :status
end

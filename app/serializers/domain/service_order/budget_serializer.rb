class Domain::ServiceOrder::BudgetSerializer < ActiveModel::Serializer
  attributes :id, :date, :total_value, :status, :created_at, :updated_at

  belongs_to :service_order
end

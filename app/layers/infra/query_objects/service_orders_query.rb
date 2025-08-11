module Infra
  module QueryObjects
    class ServiceOrdersQuery < Domain::ServiceOrder::ServiceOrder
      class << self
        def find_all(filter_params = {})
          query = all

          return query if filter_params.blank?

          filter_params.each do |key, value|
            next if value.blank?

            case key.to_sym
            when :status
              query = query.where(status: value)
            when :customer_id
              query = query.where(customer_id: value)
            when :vehicle_id
              query = query.where(vehicle_id: value)
            end
          end

          query
        end
      end
    end
  end
end

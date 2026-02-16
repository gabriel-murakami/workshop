module Infra
  module QueryObjects
    class BudgetsQuery < Domain::ServiceOrder::Budget
      class << self
        def find_all(filter_params)
          query = all

          return query if filter_params.blank?

          filter_params.each do |key, value|
            next if value.blank?

            case key.to_sym
            when :customer_id
              query = query.joins(:service_order).where(
                customer_id: value
              )
            end
          end

          query
        end
      end
    end
  end
end

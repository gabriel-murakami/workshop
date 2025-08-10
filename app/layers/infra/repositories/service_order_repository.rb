module Infra
  module Repositories
    class ServiceOrderRepository
      def initialize(model = {})
        @service_order = model.fetch(:service_order) { Domain::ServiceOrder::ServiceOrder }
      end

      def find_all
        @service_order.all
      end

      def find_by_id(service_order_id)
        @service_order.find_by!(id: service_order_id)
      end

      def update(service_order, service_order_attributes)
        service_order.update!(service_order_attributes)
      end
    end
  end
end

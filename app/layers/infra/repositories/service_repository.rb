module Infra
  module Repositories
    class ServiceRepository
      def initialize(model = {})
        @service = model.fetch(:service) { Domain::Catalog::Service }
      end

      def save(service)
        service.save!
      end

      def delete(service)
        service.destroy
      end

      def update(service, service_attributes)
        service.update!(service_attributes)
      end

      def find_by_id(service_id)
        @service.find_by!(id: service_id)
      end

      def find_all
        @service.all
      end
    end
  end
end

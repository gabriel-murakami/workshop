module Application
  module ServiceOrderItem
    class ServiceApplication
      def initialize(repositories = {})
        @service_repository = repositories.fetch(:service) { Infra::Repositories::ServiceRepository.new }
      end

      def find_all
        @service_repository.find_all
      end

      def find_by_id(service_id)
        @service_repository.find_by_id(service_id)
      end

      def create_service(create_service_command)
        service = Domain::ServiceOrderItem::Service.new(create_service_command.service)

        ActiveRecord::Base.transaction do
          @service_repository.save(service)

          service
        end
      end

      def delete_service(delete_service_command)
        service = @service_repository.find_by_id(delete_service_command.service_id)

        ActiveRecord::Base.transaction do
          @service_repository.delete(service)
        end
      end

      def update_service(update_service_command)
        service = @service_repository.find_by_id(update_service_command.service_attributes[:id])

        ActiveRecord::Base.transaction do
          @service_repository.update(service, update_service_command.service_attributes)

          service
        end
      end

      def find_services_by_codes(codes)
        Infra::QueryObjects::ServicesQuery.find_services_by_codes(codes)
      end
    end
  end
end

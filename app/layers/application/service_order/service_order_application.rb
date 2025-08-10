module Application
  module ServiceOrder
    class ServiceOrderApplication
      def initialize(repositories = {})
        @service_order_repository = repositories.fetch(:service_order) { Infra::Repositories::ServiceOrderRepository.new }
      end

      def finish_service_order(finish_service_order_command)
        service_order = @service_order_repository.find_by_id(finish_service_order_command.service_order_id)

        ActiveRecord::Base.transaction do
          service_order_repository.update(
            service_order,
            { status: "finished", service_finished_at: Time.zone.now }
          )
        end

        update_metric(service_order)
      end

      private

      def update_metric(service_order)
        update_metric_command = Commands::UpdateMetricCommand.new(
          service_started_at: service_order.service_started_at,
          service_finished_at: service_order.service_finished_at
        )

        MetricApplication.update_metric(update_metric_command)
      end
    end
  end
end

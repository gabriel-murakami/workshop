module Application
  module ServiceOrder
    class MetricApplication
      def initialize(repositories = {})
        @metric_repository = repositories.fetch(:order) { Infra::Repositories::MetricRepository.new }
      end

      def find_all
        Infra::Repositories::MetricRepository.new.find_all
      end

      def update_metric(update_metric_command)
        started_at = update_metric_command.service_started_at
        finished_at = update_metric_command.service_finished_at

        metric = nil

        ActiveRecord::Base.transaction do
          metric = @metric_repository.find_last_with_lock
          metric.add_finished_order(started_at, finished_at)
        end

        Rails.logger.tagged(
          "Metric",
          metric_id: metric&.id
        ) do
          Rails.logger.info("Metric updated")
        end
      end
    end
  end
end

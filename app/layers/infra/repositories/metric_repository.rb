module Infra
  module Repositories
    class MetricRepository
      def initialize(model = {})
        @metric = model.fetch(:metric) { Domain::ServiceOrder::Metric }
      end

      def find_all
        @metric.all
      end

      def find_last_with_lock
        @metric.order(created_at: :desc).lock(true).first
      end
    end
  end
end

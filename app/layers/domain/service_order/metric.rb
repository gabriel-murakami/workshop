module Domain
  module ServiceOrder
    class Metric < Infra::Models::ApplicationRecord
      validates :service_order_count, presence: true
      validates :average_time, presence: true

      def add_finished_order(started_at, finished_at)
        elapsed_time = (finished_at - started_at).to_i / 60.0

        new_service_order_count = metric.service_order_count + 1
        old_elapsed_time = metric.service_order_count * metric.average_time

        self.update!(
          service_order_count: new_service_order_count,
          average_time: (old_elapsed_time + elapsed_time) / new_service_order_count
        )
      end
    end
  end
end

module Domain
  module ServiceOrder
    class Metric < Infra::Models::ApplicationRecord
      validates :service_order_count, presence: true
      validates :average_time, presence: true

      def add_finished_order(started_at, finished_at)
        elapsed_time = (finished_at - started_at).to_i / 60.0
        new_service_order_count = service_order_count + 1

        new_average_time = if service_order_count.zero?
          elapsed_time
        else
          old_elapsed_time = service_order_count * average_time

          (old_elapsed_time + elapsed_time) / new_service_order_count
        end

        self.update!(
          service_order_count: new_service_order_count,
          average_time: new_average_time
        )
      end
    end
  end
end

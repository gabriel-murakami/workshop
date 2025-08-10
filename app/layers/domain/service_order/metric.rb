module Domain
  module ServiceOrder
    class Metric < Infra::Models::ApplicationRecord
      validates :service_order_count, presence: true
      validates :average_time, presence: true

      def add_finished_order(started_at, finished_at)
        elapsed_time = (finished_at - started_at).to_i / 60.0

        new_service_order_count = service_order_count + 1
        old_elapsed_time = service_order_count * average_time

        self.update!(
          service_order_count: new_service_order_count,
          average_time: (old_elapsed_time + elapsed_time) / new_service_order_count
        )
      end

      def average_time_rounded
        average_time.to_f.round(2)
      end

      def as_json(options = {})
        super(options).merge(
          "average_time" => average_time_rounded
        )
      end
    end
  end
end

module Application
  module ServiceOrder
    class ServiceOrderApplication
      def initialize(repositories = {})
        @service_order_repository = repositories.fetch(:service_order) { Infra::Repositories::ServiceOrderRepository.new }
      end

      def add_services(add_services_command)
        service_order = @service_order_repository.find_by_id(add_services_command.service_order_id)
        services = Application::ServiceOrderItem::ServiceApplication.new.find_services_by_codes(
          add_services_command.services_codes
        )

        ActiveRecord::Base.transaction do
          service_order.add_services(services)
          @service_order_repository.save(service_order)
        end
      end

      def add_auto_parts(add_auto_parts_command)
        service_order = @service_order_repository.find_by_id(add_auto_parts_command.service_order_id)
        auto_part_parms = add_auto_parts_command.auto_parts_params

        auto_parts = Application::ServiceOrderItem::AutoPartApplication.new.find_auto_parts_by_skus(
          auto_part_parms.map { |param| param[:sku] }
        )

        auto_parts_list = auto_parts.map do |auto_part|
          {
            item: auto_part,
            quantity: auto_parts_params.find { |param| param[:sku] == auto_part.sku  }[:quantity]
          }
        end

        ActiveRecord::Base.transaction do
          service_order.add_auto_parts(auto_parts_list)
          @service_order_repository.save(service_order)

          remove_auto_parts(auto_parts_list)
        end
      end

      def cancel_service_order(cancel_service_order_command)
        service_order = @service_order_repository.find_by_id(cancel_service_order_command.service_order_id)

        ActiveRecord::Base.transaction do
          replace_auto_parts(service_order)

          @service_order_repository.update(
            service_order,
            { status: "cancelled" }
          )
        end
      end

      def start_service_order(start_service_order_command)
        service_order = @service_order_repository.find_by_id(start_service_order_command.service_order_id)

        ActiveRecord::Base.transaction do
          @service_order_repository.update(
            service_order,
            { status: "in_progress", service_started_at: Time.zone.now }
          )
        end

        service_order
      end

      def finish_service_order(finish_service_order_command)
        service_order = @service_order_repository.find_by_id(finish_service_order_command.service_order_id)

        ActiveRecord::Base.transaction do
          @service_order_repository.update(
            service_order,
            { status: "finished", service_finished_at: Time.zone.now }
          )
        end

        update_metric(service_order)

        service_order
      end

      private

      def replace_auto_parts(service_order)
        service_order.service_order_items.auto_parts.each do |service_order_item|
          stock_control_command = Application::ServiceOrderItem::Commands::StockControlCommand.new(
            auto_part_id: service_order_item.item_id,
            stock_change: service_order_item.quantity
          )

          Application::ServiceOrderItem::AutoPartApplication.new.add_auto_part(stock_control_command)
        end
      end

      def remove_auto_parts(auto_parts)
        auto_parts.each do |auto_part|
          stock_control_command = Application::ServiceOrderItem::Commands::StockControlCommand.new(
            auto_part_id: auto_part[:item].id,
            stock_change: auto_part[:quantity]
          )

          Application::ServiceOrderItem::AutoPartApplication.new.remove_auto_part(stock_control_command)
        end
      end

      def update_metric(service_order)
        update_metric_command = Commands::UpdateMetricCommand.new(
          service_started_at: service_order.service_started_at,
          service_finished_at: service_order.service_finished_at
        )

        MetricApplication.new.update_metric(update_metric_command)
      end
    end
  end
end

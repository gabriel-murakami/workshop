module Application
  module ServiceOrder
    class ServiceOrderApplication
      def initialize(repositories = {})
        @service_order_repository = repositories.fetch(:service_order) { Infra::Repositories::ServiceOrderRepository.new }
      end

      def find_all(filter_params)
        Infra::QueryObjects::ServiceOrdersQuery.find_all(filter_params)
      end

      def find_by_id(service_order_id)
        @service_order_repository.find_by_id(service_order_id)
      end

      def send_to_diagnosis(send_to_diagnosis_command)
        service_order = @service_order_repository.find_by_id(send_to_diagnosis_command.service_order_id)

        ActiveRecord::Base.transaction do
          @service_order_repository.update(service_order, { status: "diagnosis" })
        end

        service_order
      end

      def send_to_approval(send_to_approval_command)
        service_order = @service_order_repository.find_by_id(send_to_approval_command.service_order_id)

        ActiveRecord::Base.transaction do
          @service_order_repository.update(service_order, { status: "waiting_approval" })
        end

        create_new_budget(service_order)

        service_order
      end

      def add_services(add_services_command)
        service_order = @service_order_repository.find_by_id(add_services_command.service_order_id)
        services = Application::ServiceOrderItem::ServiceApplication.new.find_services_by_codes(
          add_services_command.services_codes
        )

        raise Exceptions::ServiceOrderException.new("Invalid services codes") if services.empty?

        ActiveRecord::Base.transaction do
          service_order.add_services(services)
          @service_order_repository.save(service_order)
        end
      end

      def add_auto_parts(add_auto_parts_command)
        service_order = @service_order_repository.find_by_id(add_auto_parts_command.service_order_id)
        auto_parts_params = add_auto_parts_command.auto_parts_params

        auto_parts = Application::ServiceOrderItem::AutoPartApplication.new.find_auto_parts_by_skus(
          auto_parts_params.map { |param| param[:sku] }
        )

        raise Exceptions::ServiceOrderException.new("Invalid auto parts codes") if auto_parts.empty?

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

      def approve_service_order(approve_service_order_command)
        service_order = @service_order_repository.find_by_id(approve_service_order_command.service_order_id)

        ActiveRecord::Base.transaction do
          @service_order_repository.update(
            service_order,
            { status: "approved" }
          )
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

        raise Exceptions::ServiceOrderException.new("Service order already started") if service_order.in_progress?

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

        raise Exceptions::ServiceOrderException.new("Service order already finished") if service_order.finished?

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

      def create_new_budget(service_order)
        create_budget_command = Commands::CreateBudgetCommand.new(
          service_order_id: service_order.id
        )

        BudgetApplication.new.create_budget(create_budget_command)
      end

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

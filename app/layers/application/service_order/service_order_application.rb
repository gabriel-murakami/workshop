module Application
  module ServiceOrder
    class ServiceOrderApplication
      def initialize(repositories = {})
        @service_order_repository = repositories.fetch(:service_order) { Infra::Repositories::ServiceOrderRepository.new }
      end

      def find_all
        Infra::QueryObjects::ServiceOrdersQuery.find_all
      end

      def find_by_id(service_order_id)
        @service_order_repository.find_by_id(service_order_id)
      end

      def create_service_order(create_service_order_command)
        service_order = Domain::ServiceOrder::ServiceOrder.new(
          customer_id: create_service_order_command.customer_id,
          vehicle_id: create_service_order_command.vehicle_id
        )

        ActiveRecord::Base.transaction do
          @service_order_repository.save(service_order)

          service_order
        end
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

        raise Exceptions::ServiceOrderException.new("The service order is not in diagnosis") unless service_order.diagnosis?

        ActiveRecord::Base.transaction do
          @service_order_repository.update(service_order, { status: "waiting_approval" })
        end

        create_new_budget(service_order)

        service_order
      end

      def add_services(add_services_command)
        service_order = @service_order_repository.find_by_id(add_services_command.service_order_id)

        raise Exceptions::ServiceOrderException.new("The service order is not in diagnosis") unless service_order.diagnosis?

        services = Application::ServiceOrderItem::ServiceApplication.new.find_services_by_codes(
          add_services_command.services_codes
        )

        raise Exceptions::ServiceOrderException.new("Invalid services codes") if services.empty?

        ActiveRecord::Base.transaction do
          service_order.add_services(services)
          @service_order_repository.save(service_order)

          service_order
        end
      end

      def add_products(add_products_command)
        service_order = @service_order_repository.find_by_id(add_products_command.service_order_id)

        raise Exceptions::ServiceOrderException.new("The service order is not in diagnosis") unless service_order.diagnosis?

        products_params = add_products_command.products_params
        products = Application::ServiceOrderItem::ProductApplication.new.find_products_by_skus(
          products_params.map { |param| param[:sku] }
        )

        raise Exceptions::ServiceOrderException.new("Invalid products codes") if products.empty?

        products_list = products.map do |product|
          {
            item: product,
            quantity: products_params.find { |param| param[:sku] == product.sku  }[:quantity]
          }
        end

        ActiveRecord::Base.transaction do
          service_order.add_products(products_list)
          @service_order_repository.save(service_order)

          remove_products(products_list)

          service_order
        end
      end

      def approve_service_order(approve_service_order_command)
        service_order = @service_order_repository.find_by_id(approve_service_order_command.service_order_id)

        unless service_order.waiting_approval?
          raise Exceptions::ServiceOrderException.new("The service order is not waiting approval")
        end

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
          replace_products(service_order)

          @service_order_repository.update(
            service_order,
            { status: "cancelled" }
          )
        end
      end

      def start_service_order(start_service_order_command)
        service_order = @service_order_repository.find_by_id(start_service_order_command.service_order_id)

        raise Exceptions::ServiceOrderException.new("Service order already started") if service_order.in_progress?
        raise Exceptions::ServiceOrderException.new("The service order is not approved") unless service_order.approved?

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
        raise Exceptions::ServiceOrderException.new("The service order is not started") unless service_order.in_progress?

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

      def replace_products(service_order)
        service_order.service_order_items.products.each do |service_order_item|
          stock_control_command = Application::ServiceOrderItem::Commands::StockControlCommand.new(
            product_id: service_order_item.item_id,
            stock_change: service_order_item.quantity
          )

          Application::ServiceOrderItem::ProductApplication.new.add_product(stock_control_command)
        end
      end

      def remove_products(products)
        products.each do |product|
          stock_control_command = Application::ServiceOrderItem::Commands::StockControlCommand.new(
            product_id: product[:item].id,
            stock_change: product[:quantity]
          )

          Application::ServiceOrderItem::ProductApplication.new.remove_product(stock_control_command)
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

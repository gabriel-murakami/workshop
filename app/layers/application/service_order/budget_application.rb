module Application
  module ServiceOrder
    class BudgetApplication
      def initialize(repositories = {})
        @budget_repository = repositories.fetch(:budget) { Infra::Repositories::BudgetRepository.new }
        @service_order_repository = repositories.fetch(:service_order) { Infra::Repositories::ServiceOrderRepository.new }
      end

      def find_all(filter_params)
        Infra::QueryObjects::BudgetsQuery.find_all(filter_params)
      end

      def find_by_id(budget_id)
        @budget_repository.find_by_id(budget_id)
      end

      def approve_budget(approve_budget_command)
        budget = @budget_repository.find_by_id(approve_budget_command.budget_id)

        ActiveRecord::Base.transaction do
          @budget_repository.update(budget, { status: "approved" })
        end

        approve_service_order(budget)

        Rails.logger.info({ budget_id: budget.id, status: "approved", timestamp: Time.current })
      end

      def reject_budget(reject_budget_command)
        budget = @budget_repository.find_by_id(reject_budget_command.budget_id)

        ActiveRecord::Base.transaction do
          @budget_repository.update(budget, { status: "rejected" })
        end

        cancel_service_order(budget)

        Rails.logger.info({ budget_id: budget.id, status: "rejected", timestamp: Time.current })
      end

      def create_budget(create_budget_command)
        service_order = @service_order_repository.find_by_id(create_budget_command.service_order_id)

        budget = Domain::ServiceOrder::Budget.new(
          date: Date.current,
          service_order: service_order
        )

        created_budget = ActiveRecord::Base.transaction do
          budget.calculate_total_value(service_order.service_order_items)
          @budget_repository.save(budget)
          budget
        end

        Rails.logger.info({ budget_id: created_budget.id, status: "created", timestamp: Time.current })

        created_budget
      end

      private

      def cancel_service_order(budget)
        cancel_service_order_command = Commands::CancelServiceOrderCommand.new(
          service_order_id: budget.service_order_id
        )

        ServiceOrderApplication.new.cancel_service_order(cancel_service_order_command)
      end

      def approve_service_order(budget)
        approve_service_order_command = Commands::ApproveServiceOrderCommand.new(
          service_order_id: budget.service_order_id
        )

        ServiceOrderApplication.new.approve_service_order(approve_service_order_command)
      end
    end
  end
end

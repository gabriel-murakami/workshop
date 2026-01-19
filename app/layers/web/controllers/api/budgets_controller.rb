module Web
  module Controllers
    module Api
      class BudgetsController < Web::Controllers::ApplicationController
        def index
          render json: Application::ServiceOrder::BudgetApplication.new.find_all(filter_params),
            each_serializer: ::Serializers::Domain::ServiceOrder::BudgetSerializer
        end

        def show
          render json: Application::ServiceOrder::BudgetApplication.new.find_by_id(budget_params[:id]),
            serializer: ::Serializers::Domain::ServiceOrder::BudgetSerializer
        end

        def approve
          command = Application::ServiceOrder::Commands::ApproveBudgetCommand.new(budget_id: budget_params[:id])

          Application::ServiceOrder::BudgetApplication.new.approve_budget(command)

          head :ok
        end

        def reject
          command = Application::ServiceOrder::Commands::RejectBudgetCommand.new(budget_id: budget_params[:id])

          Application::ServiceOrder::BudgetApplication.new.reject_budget(command)

          head :ok
        end

        private

        def filter_params
          budget_params.slice(:document_number)
        end

        def budget_params
          params.permit(:id, :document_number)
        end
      end
    end
  end
end

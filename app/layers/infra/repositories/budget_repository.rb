module Infra
  module Repositories
    class BudgetRepository
      def initialize(model = {})
        @budget = model.fetch(:budget) { Domain::ServiceOrder::Budget }
      end

      def save(budget)
        budget.save!
      end

      def delete(budget)
        budget.destroy
      end

      def update(budget, budget_attributes)
        budget.update!(budget_attributes)
      end

      def find_by_id(budget_id)
        @budget.find_by!(id: budget_id)
      end

      def find_all
        @budget.all
      end
    end
  end
end

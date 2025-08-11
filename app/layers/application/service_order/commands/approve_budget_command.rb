module Application
  module ServiceOrder
    module Commands
      class ApproveBudgetCommand
        attr_accessor :budget_id

        def initialize(budget_id:)
          @budget_id = budget_id
        end
      end
    end
  end
end

module Application
  module Customer
    module Commands
      class DeleteCustomerCommand
        attr_accessor :customer_id

        def initialize(customer_id:)
          @customer_id = customer_id
        end
      end
    end
  end
end

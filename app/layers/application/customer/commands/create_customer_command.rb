module Application
  module Customer
    module Commands
      class CreateCustomerCommand
        attr_accessor :customer

        def initialize(customer:)
          @customer = customer
        end
      end
    end
  end
end

module Application
  module Customer
    module Commands
      class UpdateCustomerCommand
        attr_accessor :customer_attributes

        def initialize(customer_attributes:)
          @customer_attributes = customer_attributes
        end
      end
    end
  end
end

module Infra
  module QueryObjects
    class CustomersQuery < Domain::Customer::Customer
      class << self
        def all_customers
          self.includes(:vehicles)
        end
      end
    end
  end
end

module Infra
  module Repositories
    class CustomerRepository
      def initialize(model = {})
        @customer = model.fetch(:customer) { Domain::Customer::Customer }
      end

      def save(customer)
        customer.save
      end

      def find_customer_by_document_number(document_number)
        @customer.includes(:vehicles).find_by(document_number: document_number)
      end
    end
  end
end

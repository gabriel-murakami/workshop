module Infra
  module Repositories
    class CustomerRepository
      def initialize(model = {})
        @customer = model.fetch(:customer) { Domain::Customer::Customer }
      end

      def save(customer)
        customer.save!
      end

      def delete(customer)
        customer.destroy
      end

      def update(customer, customer_attributes)
        customer.update!(customer_attributes)
      end

      def find_by_document_number(document_number)
        @customer.includes(:vehicles).find_by!(document_number: document_number)
      end

      def find_by_id(customer_id)
        @customer.includes(:vehicles).find_by!(id: customer_id)
      end

      def find_all
        @customer.all
      end
    end
  end
end

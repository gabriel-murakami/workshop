module Application
  module Customer
    class CustomerApplication
      def initialize(repositories = {})
        @customer_repository = repositories.fetch(:customer) { Infra::Repositories::CustomerRepository.new }
        @vehicle_repository = repositories.fetch(:vehicle) { Infra::Repositories::VehicleRepository.new }
      end

      def find_all
        @customer_repository.find_all
      end

      def find_by_document_number(document_number)
        @customer_repository.find_by_document_number(document_number)
      end

      def create_customer(create_customer_command)
        customer = Domain::Customer::Customer.new(create_customer_command.customer)

        ActiveRecord::Base.transaction do
          @customer_repository.save(customer)

          customer
        end
      end

      def delete_customer(delete_customer_command)
        customer = @customer_repository.find_by_id(delete_customer_command.customer_id)

        ActiveRecord::Base.transaction do
          @customer_repository.delete(customer)
        end
      end

      def update_customer(update_customer_command)
        customer = @customer_repository.find_by_id(update_customer_command.customer_attributes[:id])

        ActiveRecord::Base.transaction do
          @customer_repository.update(customer, update_customer_command.customer_attributes)

          customer
        end
      end

      def add_vehicle(add_vehicle_command)
        customer = @customer_repository.find_by_document_number(add_vehicle_command.customer_document_number)
        vehicle = @vehicle_repository.find_vehicle_by_license_plate(add_vehicle_command.vehicle_license_plate)

        ActiveRecord::Base.transaction do
          customer.add_vehicle(vehicle)
          @customer_repository.save(customer)
        end
      end
    end
  end
end

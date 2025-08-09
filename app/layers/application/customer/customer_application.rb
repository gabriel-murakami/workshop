module Application
  module Customer
    class CustomerApplication
      def initialize(repositories = {})
        @customer_repository = repositories.fetch(:order) { Infra::Repositories::CustomerRepository.new }
        @vehicle_repository = repositories.fetch(:order) { Infra::Repositories::VehicleRepository.new }
      end

      def create_customer(create_customer_command)
        customer = Domain::Customer::Customer.new(create_customer_command.customer)

        ActiveRecord::Base.transaction do
          @customer_repository.save(customer)
        end
      end

      def add_vehicle(add_vehicle_command)
        customer = @customer_repository.find_customer_by_document_number(add_vehicle_command.customer_document_number)
        vehicle = @vehicle_repository.find_vehicle_by_license_plate(add_vehicle_command.vehicle_license_plate)

        ActiveRecord::Base.transaction do
          customer.add_vehicle(vehicle)
          @customer_repository.save(customer)
        end
      end

      def find_customer_by_document_number(document_number)
        @customer_repository.find_customer_by_document_number(document_number)
      end
    end
  end
end

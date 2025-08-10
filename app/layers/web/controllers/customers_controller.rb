module Web
  module Controllers
    class CustomersController < AuthController
      BASE_FIELDS = %i[id name document_number email phone]
      ADD_VEHICLE_FIELDS = %i[license_plate]

      def index
        customers = Infra::Repositories::CustomerRepository.new.find_all

        render json: customers
      end

      def show
        customer = Infra::Repositories::CustomerRepository.new.find_by_document_number(
          customer_params[:document_number]
        )

        render json: customer, include: :vehicles
      end

      def create
        customer = Application::Customer::CustomerApplication.new.create_customer(
          Application::Customer::Commands::CreateCustomerCommand.new(customer: customer_params)
        )

        render json: customer, status: :created
      end

      def update
        command = Application::Customer::Commands::UpdateCustomerCommand.new(customer_attributes: customer_params)
        customer = Application::Customer::CustomerApplication.new.update_customer(command)

        render json: customer
      end

      def destroy
        command = Application::Customer::Commands::DeleteCustomerCommand.new(customer_id: customer_params[:id])

        Application::Customer::CustomerApplication.new.delete_customer(command)

        head :ok
      end

      def add_vehicle
        command = Application::Customer::Commands::AddVehicleCommand.new(
          customer_document_number: customer_params[:document_number],
          vehicle_license_plate: permitted_params[:license_plate]
        )

        Application::Customer::CustomerApplication.new.add_vehicle(command)

        head :ok
      end

      private

      def permitted_params
        params.permit(BASE_FIELDS | ADD_VEHICLE_FIELDS)
      end

      def customer_params
        permitted_params.except(ADD_VEHICLE_FIELDS)
      end
    end
  end
end

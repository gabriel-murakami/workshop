module Web
  module Controllers
    module Api
      class CustomersController < Web::Controllers::ApplicationController
        BASE_FIELDS = %i[id name document_number email phone]
        ADD_VEHICLE_FIELDS = %i[license_plate]

        def index
          render json: Application::Customer::CustomerApplication.new.find_all,
            each_serializer: ::Serializers::Domain::Customer::CustomerSerializer
        end

        def show
          customer = Application::Customer::CustomerApplication.new.find_by_document_number(customer_params[:document_number])

          render json: customer, include: :vehicles, serializer: ::Serializers::Domain::Customer::CustomerSerializer
        end

        def create
          customer = Application::Customer::CustomerApplication.new.create_customer(
            Application::Customer::Commands::CreateCustomerCommand.new(customer: customer_params)
          )

          render json: customer, status: :created, serializer: ::Serializers::Domain::Customer::CustomerSerializer
        end

        def update
          command = Application::Customer::Commands::UpdateCustomerCommand.new(customer_attributes: customer_params)
          customer = Application::Customer::CustomerApplication.new.update_customer(command)

          render json: customer, serializer: ::Serializers::Domain::Customer::CustomerSerializer
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
end

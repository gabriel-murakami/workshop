module Web
  module Controllers
    class CustomersController < ApplicationController
      include Authenticable

      BASE_FIELDS = %i[name document_number email phone]
      ADD_VEHICLE_FIELDS = %i[license_plate]

      def index
        customers = Infra::QueryObjects::CustomersQuery.all_customers

        render json: customers
      end

      def show
        customer = Infra::Repositories::CustomerRepository.new.find_customer_by_document_number(
          permitted_params[:document_number]
        )

        render json: customer, include: :vehicles
      end

      def create
        command = Application::Customer::Commands::CreateCustomerCommand.new(customer: permitted_params)

        Application::Customer::CustomerApplication.new.create_customer(command)

        head :created
      end

      def add_vehicle
        command = Application::Customer::Commands::AddVehicleCommand.new(
          customer_document_number: permitted_params[:document_number],
          vehicle_license_plate: permitted_params[:license_plate]
        )

        Application::Customer::CustomerApplication.new.add_vehicle(command)

        head :ok
      end

      def update
      end

      def destroy
      end

      private

      def permitted_params
        params.permit(BASE_FIELDS | ADD_VEHICLE_FIELDS)
      end
    end
  end
end

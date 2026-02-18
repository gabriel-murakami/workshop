module Web
  module Controllers
    module Api
      class ServiceOrdersController < Web::Controllers::ApplicationController
        def index
          render json: Application::ServiceOrder::ServiceOrderApplication.new.find_all,
            each_serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def show
          service_order = Application::ServiceOrder::ServiceOrderApplication.new.find_by_id(params[:id])

          render json: service_order, serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def current_status
          service_order = Application::ServiceOrder::ServiceOrderApplication.new.find_by_id(params[:id])

          render json: service_order, serializer: ::Serializers::Domain::ServiceOrder::CurrentStatusSerializer
        end

        def create
          service_order = Application::ServiceOrder::ServiceOrderApplication.new.create_service_order(
            Application::ServiceOrder::Commands::CreateServiceOrderCommand.new(
              document_number: permitted_params[:document_number],
              license_plate: permitted_params[:license_plate]
            )
          )

          render json: service_order, status: :created,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def open
          service_order = Application::ServiceOrder::ServiceOrderApplication.new.open_service_order(
            Application::ServiceOrder::Commands::OpenServiceOrderCommand.new(
              document_number: permitted_params[:document_number],
              license_plate: permitted_params[:license_plate],
              services_codes: permitted_params[:services_codes],
              products_params: permitted_params[:products_params]
            )
          )

          render json: service_order, status: :created,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def send_to_diagnosis
          command = Application::ServiceOrder::Commands::SendToDiagnosisCommand.new(
            service_order_id: permitted_params[:id]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.send_to_diagnosis(command)

          render json: service_order, status: :ok,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def send_to_approval
          command = Application::ServiceOrder::Commands::SendToApprovalCommand.new(
            service_order_id: permitted_params[:id]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.send_to_approval(command)

          render json: service_order, status: :ok,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def add_services
          command = Application::ServiceOrder::Commands::AddServicesCommand.new(
            service_order_id: permitted_params[:id],
            services_codes: permitted_params[:services_codes]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.add_services(command)

          render json: service_order, include: :service_order_items,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def add_products
          command = Application::ServiceOrder::Commands::AddProductsCommand.new(
            service_order_id: permitted_params[:id],
            products_params: permitted_params[:products_params]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.add_products(command)

          render json: service_order, include: :service_order_items,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def start
          command = Application::ServiceOrder::Commands::StartServiceOrderCommand.new(
            service_order_id: permitted_params[:id]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.start_service_order(command)

          render json: service_order, status: :ok,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        def finish
          command = Application::ServiceOrder::Commands::FinishServiceOrderCommand.new(
            service_order_id: permitted_params[:id]
          )

          service_order = Application::ServiceOrder::ServiceOrderApplication.new.finish_service_order(command)

          render json: service_order, status: :ok,
            serializer: ::Serializers::Domain::ServiceOrder::ServiceOrderSerializer
        end

        private

        def permitted_params
          params.permit(
            :id,
            :license_plate,
            :document_number,
            :status,
            :customer_id,
            :vehicle_id,
            services_codes: [],
            products_params: [ :sku, :quantity ]
          )
        end
      end
    end
  end
end

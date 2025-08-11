module Web
  module Controllers
    class ServiceOrdersController < AuthController
      def index
        render json: Application::ServiceOrder::ServiceOrderApplication.new.find_all(filter_params)
      end

      def show
        service_order = Application::ServiceOrder::ServiceOrderApplication.new.find_by_id(params[:id])

        render json: service_order, include: :service_order_items
      end

      def create
        service_order = Application::ServiceOrder::ServiceOrderApplication.new.create_service_order(
          Application::ServiceOrder::Commands::CreateServiceOrderCommand.new(
            customer_id: permitted_params[:customer_id],
            vehicle_id: permitted_params[:vehicle_id]
          )
        )

        render json: service_order, status: :created
      end

      def send_to_diagnosis
        command = Application::ServiceOrder::Commands::SendToDiagnosisCommand.new(
          service_order_id: permitted_params[:id]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.send_to_diagnosis(command)

        render json: service_order, status: :ok
      end

      def send_to_approval
        command = Application::ServiceOrder::Commands::SendToApprovalCommand.new(
          service_order_id: permitted_params[:id]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.send_to_approval(command)

        render json: service_order, status: :ok
      end

      def add_services
        command = Application::ServiceOrder::Commands::AddServicesCommand.new(
          service_order_id: permitted_params[:id],
          services_codes: permitted_params[:services_codes]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.add_services(command)

        render json: service_order, include: :service_order_items
      end

      def add_products
        command = Application::ServiceOrder::Commands::AddProductsCommand.new(
          service_order_id: permitted_params[:id],
          products_params: permitted_params[:products_params]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.add_products(command)

        render json: service_order, include: :service_order_items
      end

      def start
        command = Application::ServiceOrder::Commands::StartServiceOrderCommand.new(
          service_order_id: permitted_params[:id]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.start_service_order(command)

        render json: service_order, status: :ok
      end

      def finish
        command = Application::ServiceOrder::Commands::FinishServiceOrderCommand.new(
          service_order_id: permitted_params[:id]
        )

        service_order = Application::ServiceOrder::ServiceOrderApplication.new.finish_service_order(command)

        render json: service_order, status: :ok
      end

      private

      def filter_params
        permitted_params.slice(:status, :customer_id)
      end

      def permitted_params
        params.permit(
          :id,
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

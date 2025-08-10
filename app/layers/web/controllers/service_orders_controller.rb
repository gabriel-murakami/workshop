module Web
  module Controllers
    class ServiceOrdersController < AuthController
      def index
        render json: Infra::Repositories::ServiceOrderRepository.new.find_all
      end

      def show
        render json: Infra::Repositories::ServiceOrderRepository.new.find_by_id(params[:id])
      end

      def add_services
        command = Application::ServiceOrder::Commands::AddServicesCommand.new(
          service_order_id: permitted_params[:id],
          services_codes: permitted_params[:services_codes]
        )

        Application::ServiceOrder::ServiceOrderApplication.new.add_services(command)

        head :ok
      end

      def add_auto_parts
        command = Application::ServiceOrder::Commands::AddAutoPartsCommand.new(
          service_order_id: permitted_params[:id],
          auto_parts_params: permitted_params[:auto_parts_params]
        )

        Application::ServiceOrder::ServiceOrderApplication.new.add_auto_parts(command)

        head :ok
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

      def permitted_params
        params.permit(:id, :services_codes, auto_parts_params: [ :sku, :quantity ])
      end
    end
  end
end

module Web
  module Controllers
    module Api
      class ServicesController < AuthController
        def index
          render json: Application::ServiceOrderItem::ServiceApplication.new.find_all,
            each_serializer: ::Serializers::Domain::ServiceOrderItem::ServiceSerializer
        end

        def show
          render json: Application::ServiceOrderItem::ServiceApplication.new.find_by_id(service_params[:id]),
            serializer: ::Serializers::Domain::ServiceOrderItem::ServiceSerializer
        end

        def create
          service = Application::ServiceOrderItem::ServiceApplication.new.create_service(
            Application::ServiceOrderItem::Commands::CreateServiceCommand.new(service: service_params)
          )

          render json: service, status: :created,
            serializer: ::Serializers::Domain::ServiceOrderItem::ServiceSerializer
        end

        def update
          command = Application::ServiceOrderItem::Commands::UpdateServiceCommand.new(service_attributes: service_params)
          service = Application::ServiceOrderItem::ServiceApplication.new.update_service(command)

          render json: service,
            serializer: ::Serializers::Domain::ServiceOrderItem::ServiceSerializer
        end

        def destroy
          command = Application::ServiceOrderItem::Commands::DeleteServiceCommand.new(service_id: service_params[:id])

          Application::ServiceOrderItem::ServiceApplication.new.delete_service(command)

          head :ok
        end

        private

        def service_params
          params.permit(:id, :name, :description, :base_price, :code)
        end
      end
    end
  end
end

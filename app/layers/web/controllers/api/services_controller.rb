module Web
  module Controllers
    module Api
      class ServicesController < Web::Controllers::ApplicationController
        def index
          render json: Application::Catalog::ServiceApplication.new.find_all,
            each_serializer: ::Serializers::Domain::Catalog::ServiceSerializer
        end

        def show
          render json: Application::Catalog::ServiceApplication.new.find_by_id(service_params[:id]),
            serializer: ::Serializers::Domain::Catalog::ServiceSerializer
        end

        def create
          service = Application::Catalog::ServiceApplication.new.create_service(
            Application::Catalog::Commands::CreateServiceCommand.new(service: service_params)
          )

          render json: service, status: :created,
            serializer: ::Serializers::Domain::Catalog::ServiceSerializer
        end

        def update
          command = Application::Catalog::Commands::UpdateServiceCommand.new(service_attributes: service_params)
          service = Application::Catalog::ServiceApplication.new.update_service(command)

          render json: service,
            serializer: ::Serializers::Domain::Catalog::ServiceSerializer
        end

        def destroy
          command = Application::Catalog::Commands::DeleteServiceCommand.new(service_id: service_params[:id])

          Application::Catalog::ServiceApplication.new.delete_service(command)

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

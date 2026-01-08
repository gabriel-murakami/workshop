module Web
  module Controllers
    module Api
      class MetricsController < AuthController
        def index
          render json: Application::ServiceOrder::MetricApplication.new.find_all,
            each_serializer: ::Serializers::Domain::ServiceOrder::MetricSerializer
        end
      end
    end
  end
end

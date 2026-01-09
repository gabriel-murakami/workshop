module Web
  module Controllers
    module Api
      class MetricsController < Web::Controllers::ApplicationController
        def index
          render json: Application::ServiceOrder::MetricApplication.new.find_all,
            each_serializer: ::Serializers::Domain::ServiceOrder::MetricSerializer
        end
      end
    end
  end
end

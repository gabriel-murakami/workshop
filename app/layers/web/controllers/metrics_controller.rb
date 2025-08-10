module Web
  module Controllers
    class MetricsController < AuthController
      def index
        render json: Application::ServiceOrder::MetricApplication.new.find_all
      end
    end
  end
end

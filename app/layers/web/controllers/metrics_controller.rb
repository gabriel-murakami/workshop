module Web
  module Controllers
    class MetricsController < AuthController
      def index
        render json: Infra::Repositories::MetricRepository.new.find_all
      end
    end
  end
end

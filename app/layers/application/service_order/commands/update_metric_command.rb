module Application
  module ServiceOrder
    module Commands
      class UpdateMetricCommand
        attr_accessor :service_started_at, :service_finished_at

        def initialize(service_started_at:, service_finished_at:)
          @service_started_at = service_started_at
          @service_finished_at = service_finished_at
        end
      end
    end
  end
end

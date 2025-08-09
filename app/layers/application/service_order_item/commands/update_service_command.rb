module Application
  module ServiceOrderItem
    module Commands
      class UpdateServiceCommand
        attr_accessor :service_attributes

        def initialize(service_attributes:)
          @service_attributes = service_attributes
        end
      end
    end
  end
end

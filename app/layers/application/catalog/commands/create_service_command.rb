module Application
  module Catalog
    module Commands
      class CreateServiceCommand
        attr_accessor :service

        def initialize(service:)
          @service = service
        end
      end
    end
  end
end

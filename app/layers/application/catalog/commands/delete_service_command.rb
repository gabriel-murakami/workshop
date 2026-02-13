module Application
  module Catalog
    module Commands
      class DeleteServiceCommand
        attr_accessor :service_id

        def initialize(service_id:)
          @service_id = service_id
        end
      end
    end
  end
end

module Application
  module ServiceOrder
    module Commands
      class CreateServiceOrderCommand
        attr_accessor :document_number, :license_plate

        def initialize(document_number:, license_plate:)
          @document_number = document_number
          @license_plate = license_plate
        end
      end
    end
  end
end

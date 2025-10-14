module Application
  module ServiceOrder
    module Commands
      class OpenServiceOrderCommand
        attr_accessor :document_number, :license_plate, :services_codes, :products_params

        def initialize(document_number:, license_plate:, services_codes:, products_params:)
          @document_number = document_number
          @license_plate = license_plate
          @services_codes = services_codes
          @products_params = products_params
        end
      end
    end
  end
end

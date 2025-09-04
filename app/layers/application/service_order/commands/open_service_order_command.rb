module Application
  module ServiceOrder
    module Commands
      class OpenServiceOrderCommand
        attr_accessor :service_order_id, :document_number, :license_plate, :services_codes, :products_params

        def initialize(service_order_id:, document_number:, license_plate:, services_codes:, products_params:)
          @service_order_id = service_order_id
          @document_number = document_number
          @license_plate = license_plate
          @services_codes = services_codes
          @products_params = products_params
        end
      end
    end
  end
end

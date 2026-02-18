module Infra
  module Clients
    class CustomerServiceClient
      DEFAULT_TIMEOUT = 5
      DEFAULT_OPEN_TIMEOUT = 2

      def initialize(base_url: ENV.fetch("CUSTOMER_SERVICE_URL"))
        @conn = Faraday.new(
          url: base_url,
          request: {
            open_timeout: DEFAULT_OPEN_TIMEOUT,
            timeout: DEFAULT_TIMEOUT
          }
        ) do |f|
          f.request :json
          f.response :json, parser_options: { symbolize_names: true }
          f.adapter Faraday.default_adapter
        end
      end

      def find_customer(search_param)
        handle_response(@conn.get("/api/customers/#{search_param}"))
      end

      def vehicle_by_license_plate(plate)
        handle_response(@conn.get("/api/vehicles/#{plate}"))
      end

      private

      def handle_response(response)
        return response.body.with_indifferent_access if response.success?

        raise ExternalServiceError.new(response.status, response.body)
      end
    end

    class ExternalServiceError < StandardError
      attr_reader :status, :body

      def initialize(status, body)
        @status = status
        @body = body
        super("External service error (#{status}): #{body}")
      end
    end
  end
end

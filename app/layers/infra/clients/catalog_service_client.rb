module Infra
  module Clients
    class CatalogServiceClient
      DEFAULT_TIMEOUT = 5
      DEFAULT_OPEN_TIMEOUT = 2

      def initialize(base_url: ENV.fetch("CATALOG_SERVICE_URL"))
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

      def products_by_sku(skus)
        handle_response(@conn.get("/api/products", { search_params: skus }))
      end

      def services_by_codes(codes)
        handle_response(@conn.get("/api/services", { search_params: codes }))
      end

      def add_product(params)
        handle_response(@conn.post("/api/products/#{params[:id]}/add", { stock_change: params[:stock_change] }))
      end

      def remove_product(params)
        handle_response(@conn.post("/api/products/#{params[:id]}/remove", { stock_change: params[:stock_change] }))
      end

      private

      def handle_response(response)
        if response.success?
          if response.body.is_a?(Array)
            return response.body.map { |item| item.with_indifferent_access }
          else
            return response.body.with_indifferent_access
          end
        end

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

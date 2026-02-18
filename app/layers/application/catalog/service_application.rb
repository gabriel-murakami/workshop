module Application
  module Catalog
    class ServiceApplication
      def initialize(client: Infra::Clients::CatalogServiceClient.new)
        @client = client
      end

      def find_services_by_codes(codes)
        @client.services_by_codes(codes)
      end
    end
  end
end

module Application
  module Catalog
    class ProductApplication
      def initialize(client: Infra::Clients::CatalogServiceClient.new)
        @client = client
      end

      def find_products_by_skus(skus)
        @client.products_by_sku(skus)
      end

      def remove_product(params)
        @client.remove_product(params)
      end

      def add_product(params)
        @client.add_product(params)
      end
    end
  end
end

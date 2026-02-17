module Application
  module Customer
    class CustomerApplication
      def initialize(client: Infra::Clients::CustomerServiceClient.new)
        @client = client
      end

      def find_by_document_number(document_number)
        @client.customer_by_document(document_number)
      end
    end
  end
end

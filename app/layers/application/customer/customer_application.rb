module Application
  module Customer
    class CustomerApplication
      def initialize(client: Infra::Clients::CustomerServiceClient.new)
        @client = client
      end

      def find(search_param)
        @client.find_customer(search_param)
      end
    end
  end
end

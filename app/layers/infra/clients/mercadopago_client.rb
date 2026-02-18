require "mercadopago"

module Infra
  module Clients
    class MercadopagoClient
      attr_reader :service_order_id

      def initialize(service_order_id: nil)
        @service_order_id = service_order_id
      end

      def create_order(amount)
        create_preference(amount)[:response]
      end

      def get_payment(payment_id)
        sdk.payment.get(payment_id)[:response]
      end

      private

      def sdk
        Mercadopago::SDK.new(ENV["MERCADOPAGO_TOKEN"])
      end

      def create_preference(amount)
        data = {
          items: [
            {
              id: "service-order-#{service_order_id}",
              title: "Ordem de Serviço #{service_order_id}",
              quantity: 1,
              unit_price: amount.to_f
            }
          ],
          external_reference: service_order_id,
          notification_url: ENV["WEBHOOK_URL"]
        }

        sdk.preference.create(data)
      rescue MercadoPago::MPApiException => e
        puts "Status code: #{e.api_response.status_code}"
        puts "Content: #{e.api_response.content}"
      rescue StandardError => e
        puts e.message
      end
    end
  end
end

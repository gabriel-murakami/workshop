module Web
  module Controllers
    module Webhooks
      class PaymentsController < Web::Controllers::ApplicationController
        def create
          return head :ok if params["topic"] == "merchant_order"

          EventBus::Publisher.publish(
            "payment.webhook.received",
            {
              external_payment_id: params["data"]["id"]
            }
          )
        end
      end
    end
  end
end

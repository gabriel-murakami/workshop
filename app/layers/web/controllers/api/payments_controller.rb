module Web
  module Controllers
    module Api
      class PaymentsController < Web::Controllers::ApplicationController
        def index
          render json: Domain::ServiceOrder::Payment.all
        end
      end
    end
  end
end

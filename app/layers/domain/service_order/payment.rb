module Domain
  module ServiceOrder
    class Payment
      include Mongoid::Document
      include Mongoid::Timestamps

      field :service_order_id, type: String
      field :amount, type: BigDecimal
      field :external_id, type: String
      field :status, type: String
      field :provider_payload, type: Hash
    end
  end
end

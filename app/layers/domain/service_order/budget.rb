module Domain
  module ServiceOrder
    class Budget < Infra::Models::ApplicationRecord
      belongs_to :service_order

      enum status: {
        pending: "pending",
        approved: "approved",
        rejected: "rejected"
      }

      validates :date, presence: true
      validates :status, presence: true
      validates :total_value, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end

module Domain
  module Customer
    class Customer < Infra::Models::ApplicationRecord
      has_many :vehicles, dependent: :destroy
      has_many :service_orders, dependent: :destroy
      has_many :budgets, through: :service_orders

      validates :name, presence: true
      validates :document_number, presence: true, uniqueness: true
    end
  end
end

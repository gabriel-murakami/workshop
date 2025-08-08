module Domain
  module Customer
    class Vehicle < Infra::Models::ApplicationRecord
      belongs_to :customer
      has_many :service_orders, dependent: :destroy

      validates :license_plate, presence: true, uniqueness: true
    end
  end
end

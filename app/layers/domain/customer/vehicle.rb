module Domain
  module Customer
    class Vehicle < Infra::Models::ApplicationRecord
      belongs_to :customer, optional: true
      has_many :service_orders, class_name: "Domain::ServiceOrder::ServiceOrder", dependent: :destroy

      validates :license_plate, presence: true, uniqueness: true
    end
  end
end

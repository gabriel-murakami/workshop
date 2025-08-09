module Domain
  module Customer
    class Customer < Infra::Models::ApplicationRecord
      has_many :vehicles
      has_many :service_orders, class_name: "Domain::ServiceOrder::ServiceOrder", dependent: :destroy
      has_many :budgets, class_name: "Domain::ServiceOrder::Budget", through: :service_orders

      validates :name, presence: true
      validates :document_number, presence: true, uniqueness: true

      def add_vehicle(vehicle)
        if vehicle_already_have_owner?(vehicle)
          raise Exceptions::CustomerException.new("Vehicle already have owner")
        end

        self.vehicles << vehicle
      end

      private

      def vehicle_already_have_owner?(vehicle)
        vehicle.customer_id.present? && vehicle.customer != self
      end
    end
  end
end

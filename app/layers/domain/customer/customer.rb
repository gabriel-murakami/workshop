require "cpf_cnpj"

module Domain
  module Customer
    class Customer < Infra::Models::ApplicationRecord
      has_many :vehicles
      has_many :service_orders, class_name: "Domain::ServiceOrder::ServiceOrder", dependent: :destroy
      has_many :budgets, class_name: "Domain::ServiceOrder::Budget", through: :service_orders

      validates :name, presence: true
      validates :document_number, presence: true, uniqueness: true
      validate  :validate_document_number

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

      def validate_document_number
        normalized = document_number.to_s.gsub(/\D/, "")

        valid = if normalized.length == 11
          CPF.valid?(normalized)
        elsif normalized.length == 14
          CNPJ.valid?(normalized)
        else
          false
        end

        errors.add(:document_number, "is not a valid CPF or CNPJ") unless valid
      end
    end
  end
end

module Domain
  module Customer
    class Vehicle < Infra::Models::ApplicationRecord
      belongs_to :customer, optional: true
      has_many :service_orders, class_name: "Domain::ServiceOrder::ServiceOrder", dependent: :destroy

      validates :license_plate, presence: true, uniqueness: true
      validate  :license_plate_format

      private

      def license_plate_format
        return if license_plate.blank?

        valid_format = license_plate.match?(/\A([A-Z]{3}[0-9]{4}|[A-Z]{3}[0-9][A-Z][0-9]{2})\z/i)

        unless valid_format
          errors.add(:license_plate, "is not a valid Brazilian license plate")
        end
      end
    end
  end
end

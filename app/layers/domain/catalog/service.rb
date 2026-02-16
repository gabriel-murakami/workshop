module Domain
  module Catalog
    class Service < Infra::Models::ApplicationRecord
      validates :code, presence: true, uniqueness: true,
                       format: { with: /\ASVC\d{3}\z/, message: "must be in the format 'SVC' followed by 3 digits" }
      validates :name, presence: true
      validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end

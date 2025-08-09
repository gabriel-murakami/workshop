module Infra
  module QueryObjects
    class VehiclesQuery < Domain::Customer::Vehicle
      class << self
        def all_vehicles
          self.all
        end
      end
    end
  end
end

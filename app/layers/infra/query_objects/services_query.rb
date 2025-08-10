module Infra
  module QueryObjects
    class ServicesQuery < Domain::ServiceOrderItem::Service
      class << self
        def services_by_code(codes)
          self.where(code: codes)
        end
      end
    end
  end
end

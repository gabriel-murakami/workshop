module Infra
  module QueryObjects
    class ServicesQuery < Domain::Catalog::Service
      class << self
        def find_services_by_codes(codes)
          self.where(code: codes)
        end
      end
    end
  end
end

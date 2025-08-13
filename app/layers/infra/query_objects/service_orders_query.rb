module Infra
  module QueryObjects
    class ServiceOrdersQuery < Domain::ServiceOrder::ServiceOrder
      class << self
        def find_all
          self
            .where("status NOT IN ('finished', 'delivered', 'cancelled')")
            .order(
              Arel.sql(
                <<~TXT
                  CASE status
                  WHEN 'received' THEN 1
                  WHEN 'diagnosis' THEN 2
                  WHEN 'waiting_approval' THEN 3
                  WHEN 'approved' THEN 4
                  WHEN 'in_progress' THEN 5
                  END
                TXT
              )
            )
        end
      end
    end
  end
end

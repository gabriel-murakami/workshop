module Application
  module ServiceOrderItem
    module Commands
      class DeleteAutoPartCommand
        attr_accessor :auto_part_id

        def initialize(auto_part_id:)
          @auto_part_id = auto_part_id
        end
      end
    end
  end
end

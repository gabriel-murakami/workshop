module Application
  module ServiceOrderItem
    module Commands
      class UpdateAutoPartCommand
        attr_accessor :auto_part_attributes

        def initialize(auto_part_attributes:)
          @auto_part_attributes = auto_part_attributes
        end
      end
    end
  end
end

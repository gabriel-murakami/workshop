module Application
  module ServiceOrderItem
    module Commands
      class CreateAutoPartCommand
        attr_accessor :auto_part

        def initialize(auto_part:)
          @auto_part = auto_part
        end
      end
    end
  end
end

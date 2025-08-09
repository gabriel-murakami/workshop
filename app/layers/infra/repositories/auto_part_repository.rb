module Infra
  module Repositories
    class AutoPartRepository
      def initialize(model = {})
        @auto_part = model.fetch(:auto_part) { Domain::ServiceOrderItem::AutoPart }
      end

      def save(auto_part)
        auto_part.save!
      end

      def delete(auto_part)
        auto_part.destroy
      end

      def update(auto_part, auto_part_attributes)
        auto_part.update!(auto_part_attributes)
      end

      def find_by_id(auto_part_id)
        @auto_part.find_by!(id: auto_part_id)
      end

      def find_all
        @auto_part.all
      end
    end
  end
end

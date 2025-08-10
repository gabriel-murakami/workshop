module Application
  module ServiceOrderItem
    class AutoPartApplication
      def initialize(repositories = {})
        @auto_part_repository = repositories.fetch(:auto_part) { Infra::Repositories::AutoPartRepository.new }
      end

      def find_all
        @auto_part_repository.find_all
      end

      def find_by_id(auto_part_id)
        @auto_part_repository.find_by_id(auto_part_id)
      end

      def add_auto_part(stock_control_command)
        auto_part = @auto_part_repository.find_by_id(stock_control_command.auto_part_id)

        ActiveRecord::Base.transaction do
          auto_part.add_auto_part(stock_control_command.stock_change)
          @auto_part_repository.save(auto_part)

          auto_part
        end
      end

      def remove_auto_part(stock_control_command)
        auto_part = @auto_part_repository.find_by_id(stock_control_command.auto_part_id)

        ActiveRecord::Base.transaction do
          auto_part.remove_auto_part(stock_control_command.stock_change)
          @auto_part_repository.save(auto_part)

          auto_part
        end
      end

      def create_auto_part(create_auto_part_command)
        auto_part = Domain::ServiceOrderItem::AutoPart.new(create_auto_part_command.auto_part)

        ActiveRecord::Base.transaction do
          @auto_part_repository.save(auto_part)

          auto_part
        end
      end

      def delete_auto_part(delete_auto_part_command)
        auto_part = @auto_part_repository.find_by_id(delete_auto_part_command.auto_part_id)

        ActiveRecord::Base.transaction do
          @auto_part_repository.delete(auto_part)
        end
      end

      def update_auto_part(update_auto_part_command)
        auto_part = @auto_part_repository.find_by_id(update_auto_part_command.auto_part_attributes[:id])

        ActiveRecord::Base.transaction do
          @auto_part_repository.update(auto_part, update_auto_part_command.auto_part_attributes)

          auto_part
        end
      end

      def find_auto_parts_by_skus(skus)
        Infra::QueryObjects::AutoPartsQuery.find_auto_parts_by_sku(skus)
      end
    end
  end
end

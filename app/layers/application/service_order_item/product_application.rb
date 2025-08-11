module Application
  module ServiceOrderItem
    class ProductApplication
      def initialize(repositories = {})
        @product_repository = repositories.fetch(:product) { Infra::Repositories::ProductRepository.new }
      end

      def find_all
        @product_repository.find_all
      end

      def find_by_id(product_id)
        @product_repository.find_by_id(product_id)
      end

      def add_product(stock_control_command)
        product = @product_repository.find_by_id(stock_control_command.product_id)

        ActiveRecord::Base.transaction do
          product.add_product(stock_control_command.stock_change)
          @product_repository.save(product)

          product
        end
      end

      def remove_product(stock_control_command)
        product = @product_repository.find_by_id(stock_control_command.product_id)

        ActiveRecord::Base.transaction do
          product.remove_product(stock_control_command.stock_change)
          @product_repository.save(product)

          product
        end
      end

      def create_product(create_product_command)
        product = Domain::ServiceOrderItem::Product.new(create_product_command.product)

        ActiveRecord::Base.transaction do
          @product_repository.save(product)

          product
        end
      end

      def delete_product(delete_product_command)
        product = @product_repository.find_by_id(delete_product_command.product_id)

        ActiveRecord::Base.transaction do
          @product_repository.delete(product)
        end
      end

      def update_product(update_product_command)
        product = @product_repository.find_by_id(update_product_command.product_attributes[:id])

        ActiveRecord::Base.transaction do
          @product_repository.update(product, update_product_command.product_attributes)

          product
        end
      end

      def find_products_by_skus(skus)
        Infra::QueryObjects::ProductsQuery.find_products_by_sku(skus)
      end
    end
  end
end

module Infra
  module Repositories
    class ProductRepository
      def initialize(model = {})
        @product = model.fetch(:product) { Domain::Catalog::Product }
      end

      def save(product)
        product.save!
      end

      def delete(product)
        product.destroy
      end

      def update(product, product_attributes)
        product.update!(product_attributes)
      end

      def find_by_id(product_id)
        @product.find_by!(id: product_id)
      end

      def find_all
        @product.all
      end
    end
  end
end

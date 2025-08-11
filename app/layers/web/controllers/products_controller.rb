module Web
  module Controllers
    class ProductsController < AuthController
      PRODUCTS_FIELDS = %i[id name description stock_quantity base_price sku]
      STOCK_CONTROL_FIELDS = %i[stock_change]

      def index
        render json: Application::ServiceOrderItem::ProductApplication.new.find_all
      end

      def show
        render json: Application::ServiceOrderItem::ProductApplication.new.find_by_id(product_params[:id])
      end

      def create
        product = Application::ServiceOrderItem::ProductApplication.new.create_product(
          Application::ServiceOrderItem::Commands::CreateProductCommand.new(product: product_params)
        )

        render json: product, status: :created
      end

      def update
        command = Application::ServiceOrderItem::Commands::UpdateProductCommand.new(product_attributes: update_params)
        product = Application::ServiceOrderItem::ProductApplication.new.update_product(command)

        render json: product
      end

      def add_products
        product = Application::ServiceOrderItem::ProductApplication.new.add_product(stock_control_command)

        render json: product
      end

      def remove_products
        product = Application::ServiceOrderItem::ProductApplication.new.remove_product(stock_control_command)

        render json: product
      end

      def destroy
        command = Application::ServiceOrderItem::Commands::DeleteProductCommand.new(product_id: product_params[:id])

        Application::ServiceOrderItem::ProductApplication.new.delete_product(command)

        head :ok
      end

      private

      def stock_control_command
        Application::ServiceOrderItem::Commands::StockControlCommand.new(
          product_id: product_params[:id],
          stock_change: product_params[:stock_change]
        )
      end

      def product_params
        params.permit(PRODUCTS_FIELDS | STOCK_CONTROL_FIELDS)
      end

      def update_params
        product_params.except(:stock_quantity)
      end
    end
  end
end

module Web
  module Controllers
    class AutoPartsController < ApplicationController
      AUTO_PARTS_FIELDS = %i[id name description stock_quantity base_price]
      STOCK_CONTROL_FIELDS = %i[stock_change]

      def index
        auto_parts = Infra::Repositories::AutoPartRepository.new.find_all
        render json: auto_parts
      end

      def show
        auto_part = Infra::Repositories::AutoPartRepository.new.find_by_id(auto_part_params[:id])

        render json: auto_part
      end

      def create
        auto_part = Application::ServiceOrderItem::AutoPartApplication.new.create_auto_part(
          Application::ServiceOrderItem::Commands::CreateAutoPartCommand.new(auto_part: auto_part_params)
        )

        render json: auto_part, status: :created
      end

      def update
        command = Application::ServiceOrderItem::Commands::UpdateAutoPartCommand.new(auto_part_attributes: update_params)
        auto_part = Application::ServiceOrderItem::AutoPartApplication.new.update_auto_part(command)

        render json: auto_part
      end

      def add_auto_parts
        auto_part = Application::ServiceOrderItem::AutoPartApplication.new.add_auto_part(stock_control_command)

        render json: auto_part
      end

      def remove_auto_parts
        auto_part = Application::ServiceOrderItem::AutoPartApplication.new.remove_auto_part(stock_control_command)

        render json: auto_part
      end

      def destroy
        command = Application::ServiceOrderItem::Commands::DeleteAutoPartCommand.new(auto_part_id: auto_part_params[:id])

        Application::ServiceOrderItem::AutoPartApplication.new.delete_auto_part(command)

        head :ok
      end

      private

      def stock_control_command
        Application::ServiceOrderItem::Commands::StockControlCommand.new(
          auto_part_id: auto_part_params[:id],
          stock_change: auto_part_params[:stock_change]
        )
      end

      def auto_part_params
        params.permit(AUTO_PARTS_FIELDS | STOCK_CONTROL_FIELDS)
      end

      def update_params
        auto_part_params.except(:stock_quantity)
      end
    end
  end
end

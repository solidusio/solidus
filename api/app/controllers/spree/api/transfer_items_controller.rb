module Spree
  module Api
    class TransferItemsController < Spree::Api::BaseController
      def update
        @transfer_item = TransferItem.accessible_by(current_ability, :update).find(params[:id])
        if @transfer_item.update_attributes(transfer_item_params)
          respond_with(@transfer_item, status: 200, default_template: :show)
        else
          invalid_resource!(@transfer_item)
        end
      end

      def receive
        stock_transfer = Spree::StockTransfer.accessible_by(current_ability, :update).find_by!(number: params[:stock_transfer_id])
        variant = Spree::Variant.accessible_by(current_ability, :show).find(params[:variant_id])
        @transfer_item = stock_transfer.transfer_items.find_by!(variant: variant)
        if @transfer_item.update_attributes(received_quantity: @transfer_item.received_quantity + 1)
          respond_with(@transfer_item, status: 200, default_template: :show)
        else
          invalid_resource!(@transfer_item)
        end
      end

      private

      def transfer_item_params
        params.require(:transfer_item).permit(permitted_transfer_item_attributes)
      end
    end
  end
end

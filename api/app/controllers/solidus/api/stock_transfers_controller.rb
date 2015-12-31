module Spree
  module Api
    class StockTransfersController < Spree::Api::BaseController
      def receive
        authorize! :update, TransferItem
        @stock_transfer = Spree::StockTransfer.accessible_by(current_ability, :update).find_by!(number: params[:id])
        variant = Spree::Variant.accessible_by(current_ability, :show).find(params[:variant_id])
        @transfer_item = @stock_transfer.transfer_items.find_by(variant: variant)
        if @transfer_item.nil?
          logger.error("variant_not_in_stock_transfer")
          render "spree/api/errors/variant_not_in_stock_transfer", status: 422
        elsif @transfer_item.update_attributes(received_quantity: @transfer_item.received_quantity + 1)
          render 'spree/api/stock_transfers/receive', status: 200
        else
          invalid_resource!(@transfer_item)
        end
      end
    end
  end
end

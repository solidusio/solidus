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

      private

      def transfer_item_params
        params.require(:transfer_item).permit(permitted_transfer_item_attributes)
      end
    end
  end
end

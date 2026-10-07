# frozen_string_literal: true

module Spree
  module Admin
    class ReturnItemsController < ResourceController
      private

      def permitted_resource_params
        params.require(:return_item).permit(:acceptance_status, :reception_status_event)
      end

      def location_after_save
        url_for([:edit, :admin, @return_item.customer_return.order, @return_item.customer_return])
      end

      def render_after_update_error
        redirect_back(fallback_location: location_after_save,
          flash: {error: @object.errors.full_messages.join(", ")})
      end
    end
  end
end

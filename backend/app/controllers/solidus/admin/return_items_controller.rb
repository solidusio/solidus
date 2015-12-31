module Spree
  module Admin
    class ReturnItemsController < ResourceController

      private

      def location_after_save
        url_for([:edit, :admin, @return_item.customer_return.order, @return_item.customer_return])
      end

      def render_after_update_error
        redirect_to :back, flash: { error: @object.errors.full_messages.join(', ') }
      end
    end
  end
end

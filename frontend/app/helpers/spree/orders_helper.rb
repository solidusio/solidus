module Spree
  module OrdersHelper
    def order_just_completed?(order)
      flash[:order_completed] && order.present?
    end

    def link_to_tracking(shipment, options = {})
      return unless shipment.tracking && shipment.shipping_method

      if shipment.tracking_url
        link_to(shipment.tracking, shipment.tracking_url, options)
      else
        content_tag(:span, shipment.tracking)
      end
    end
  end
end

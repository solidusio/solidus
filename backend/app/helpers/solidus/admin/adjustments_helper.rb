module Spree
  module Admin
    module AdjustmentsHelper
      def adjustment_state(adjustment)
        icon = adjustment.finalized? ? 'lock' : 'unlock'
        content_tag(:span, '', class: "fa fa-#{icon}")
      end

      def display_adjustable(adjustable)
        case adjustable
          when Solidus::LineItem
            display_line_item(adjustable)
          when Solidus::Shipment
            display_shipment(adjustable)
          when Solidus::Order
            display_order(adjustable)
        end

      end

      private

      def display_line_item(line_item)
        variant = line_item.variant
        parts = []
        parts << variant.product.name
        parts << "(#{variant.options_text})" if variant.options_text.present?
        parts << line_item.display_total
        parts.join("<br>").html_safe
      end

      def display_shipment(shipment)
        "#{Solidus.t(:shipment)} ##{shipment.number}<br>#{shipment.display_cost}".html_safe
      end

      def display_order(order)
        Solidus.t(:order)
      end
    end
  end
end

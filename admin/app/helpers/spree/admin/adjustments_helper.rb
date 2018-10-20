# frozen_string_literal: true

module Spree
  module Admin
    module AdjustmentsHelper
      def adjustment_state(adjustment)
        icon = adjustment.finalized? ? 'lock' : 'unlock'
        content_tag(:span, '', class: "fa fa-#{icon}")
      end

      def display_adjustable(adjustable)
        case adjustable
        when Spree::LineItem
            display_line_item(adjustable)
        when Spree::Shipment
            display_shipment(adjustable)
        when Spree::Order
            display_order(adjustable)
        end
      end

      private

      def display_line_item(line_item)
        variant = line_item.variant
        parts = []
        parts << variant.product.name
        parts << "(#{variant.options_text})" if variant.options_text.present?
        parts << line_item.display_amount
        safe_join(parts, "<br />".html_safe)
      end

      def display_shipment(shipment)
        parts = [
          "#{t('spree.shipment')} ##{shipment.number}",
          shipment.display_cost
        ]
        safe_join(parts, "<br />".html_safe)
      end

      def display_order(_order)
        t('spree.order')
      end
    end
  end
end

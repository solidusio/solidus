# frozen_string_literal: true

module Spree
  module Admin
    module StockMovementsHelper
      def pretty_originator(stock_movement)
        originator = stock_movement.originator

        if originator.respond_to?(:number)
          if originator.respond_to?(:order)
            link_to originator.number, [:edit, :admin, originator.order]
          else
            originator.number
          end
        elsif originator.respond_to?(:email)
          originator.email
        else
          ""
        end
      end

      def display_variant(stock_movement)
        variant = stock_movement.stock_item.variant
        output = [variant.name]
        output << variant.options_text unless variant.options_text.blank?
        safe_join(output, "<br />".html_safe)
      end
    end
  end
end

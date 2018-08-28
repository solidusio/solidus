# frozen_string_literal: true

module Spree
  class MailerPreviews
    class OrderPreview < ActionMailer::Preview
      def confirm
        order = Order.complete.last
        raise "Your database needs at least one completed order to render this preview" unless order
        Spree::Config.order_mailer_class.confirm_email(order)
      end

      def cancel
        order = Order.with_state(:canceled).last
        raise "Your database needs at least one cancelled order to render this preview" unless order
        Spree::Config.order_mailer_class.cancel_email(order)
      end

      def inventory_cancellation
        order = Spree::Order.joins(:inventory_units).merge(Spree::InventoryUnit.canceled).last
        raise "Your database needs at least one order with a canceled inventory unit to render this preview" unless order
        Spree::Config.order_mailer_class.inventory_cancellation_email(order, [order.inventory_units.first])
      end
    end
  end
end

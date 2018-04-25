# frozen_string_literal: true

module Spree
  class OrderUpdater
    attr_reader :order
    delegate :payments, :line_items, :adjustments, :all_adjustments, :shipments, :update_hooks, :quantity, to: :order

    def initialize(order)
      @order = order
    end

    # This is a multi-purpose method for processing logic related to changes in the Order.
    # It is meant to be called from various observers so that the Order is aware of changes
    # that affect totals and other values stored in the Order.
    #
    # This method should never do anything to the Order that results in a save call on the
    # object with callbacks (otherwise you will end up in an infinite recursion as the
    # associations try to save and then in turn try to call +update!+ again.)
    def update
      @order.transaction do
        update_item_count
        update_shipment_amounts
        update_totals
        if order.completed?
          update_payment_state
          update_shipments
          update_shipment_state
        end
        run_hooks
        persist_totals
      end
    end

    def run_hooks
      update_hooks.each { |hook| order.send hook }
    end

    # Updates the +shipment_state+ attribute according to the following logic:
    #
    # shipped   when all Shipments are in the "shipped" state
    # partial   when at least one Shipment has a state of "shipped" and there is another Shipment with a state other than "shipped"
    #           or there are InventoryUnits associated with the order that have a state of "sold" but are not associated with a Shipment.
    # ready     when all Shipments are in the "ready" state
    # backorder when there is backordered inventory associated with an order
    # pending   when all Shipments are in the "pending" state
    #
    # The +shipment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
    def update_shipment_state
      log_state_change('shipment') do
        order.shipment_state = determine_shipment_state
      end

      order.shipment_state
    end

    # Updates the +payment_state+ attribute according to the following logic:
    #
    # paid          when +payment_total+ is equal to +total+
    # balance_due   when +payment_total+ is less than +total+
    # credit_owed   when +payment_total+ is greater than +total+
    # failed        when most recent payment is in the failed state
    # void          when the order has been canceled and the payment total is 0
    #
    # The +payment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
    def update_payment_state
      log_state_change('payment') do
        order.payment_state = determine_payment_state
      end

      order.payment_state
    end

    private

    def determine_payment_state
      if payments.present? && payments.valid.empty? && order.outstanding_balance != 0
        'failed'
      elsif order.state == 'canceled' && order.payment_total.zero?
        'void'
      elsif order.outstanding_balance > 0
        'balance_due'
      elsif order.outstanding_balance < 0
        'credit_owed'
      else
        # outstanding_balance == 0
        'paid'
      end
    end

    def determine_shipment_state
      if order.backordered?
        'backorder'
      else
        # get all the shipment states for this order
        shipment_states = shipments.states
        if shipment_states.size > 1
          # multiple shiment states means it's most likely partially shipped
          'partial'
        else
          # will return nil if no shipments are found
          shipment_states.first
        end
      end
    end

    # This will update and select the best promotion adjustment, update tax
    # adjustments, update cancellation adjustments, and then update the total
    # fields (promo_total, included_tax_total, additional_tax_total, and
    # adjustment_total) on the item.
    # @return [void]
    def recalculate_adjustments
      # Promotion adjustments must be applied first, then tax adjustments.
      # This fits the criteria for VAT tax as outlined here:
      # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
      # It also fits the criteria for sales tax as outlined here:
      # http://www.boe.ca.gov/formspubs/pub113/
      update_item_promotions
      update_order_promotions
      update_taxes
      update_cancellations
      update_item_totals
    end

    # Updates the following Order total values:
    #
    # +payment_total+      The total value of all finalized Payments (NOTE: non-finalized Payments are excluded)
    # +item_total+         The total value of all LineItems
    # +adjustment_total+   The total value of all adjustments (promotions, credits, etc.)
    # +promo_total+        The total value of all promotion adjustments
    # +total+              The so-called "order total."  This is equivalent to +item_total+ plus +adjustment_total+.
    def update_totals
      update_payment_total
      update_item_total
      update_shipment_total
      update_adjustment_total
    end

    def update_shipment_amounts
      shipments.each do |shipment|
        shipment.update_amounts
      end
    end

    # give each of the shipments a chance to update themselves
    def update_shipments
      shipments.each do |shipment|
        shipment.update_state
      end
    end

    def update_payment_total
      order.payment_total = payments.completed.includes(:refunds).map { |payment| payment.amount - payment.refunds.sum(:amount) }.sum
    end

    def update_shipment_total
      order.shipment_total = shipments.to_a.sum(&:cost)
      update_order_total
    end

    def update_order_total
      order.total = order.item_total + order.shipment_total + order.adjustment_total
    end

    def update_adjustment_total
      recalculate_adjustments

      all_items = line_items + shipments

      order.adjustment_total = all_items.sum(&:adjustment_total) + adjustments.select(&:eligible?).sum(&:amount)
      order.included_tax_total = all_items.sum(&:included_tax_total)
      order.additional_tax_total = all_items.sum(&:additional_tax_total)

      order.promo_total = all_items.sum(&:promo_total) + adjustments.select(&:eligible?).select(&:promotion?).sum(&:amount)

      update_order_total
    end

    def update_item_count
      order.item_count = line_items.to_a.sum(&:quantity)
    end

    def update_item_total
      order.item_total = line_items.to_a.sum(&:amount)
      update_order_total
    end

    def persist_totals
      order.save!(validate: false)
    end

    def log_state_change(name)
      state = "#{name}_state"
      old_state = order.public_send(state)
      yield
      new_state = order.public_send(state)
      if old_state != new_state
        order.state_changes.new(
          previous_state: old_state,
          next_state:     new_state,
          name:           name,
          user_id:        order.user_id
        )
      end
    end

    def update_item_promotions
      [*line_items, *shipments].each do |item|
        promotion_adjustments = item.adjustments.select(&:promotion?)

        promotion_adjustments.each(&:recalculate)
        Spree::Config.promotion_chooser_class.new(promotion_adjustments).update

        item.promo_total = promotion_adjustments.select(&:eligible?).sum(&:amount)
      end
    end

    # Update and select the best promotion adjustment for the order.
    # We don't update the order.promo_total yet. Order totals are updated later
    # in #update_adjustment_total since they include the totals from the order's
    # line items and/or shipments.
    def update_order_promotions
      promotion_adjustments = order.adjustments.select(&:promotion?)
      promotion_adjustments.each(&:recalculate)
      Spree::Config.promotion_chooser_class.new(promotion_adjustments).update
    end

    def update_taxes
      Spree::Config.tax_adjuster_class.new(order).adjust!

      [*line_items, *shipments].each do |item|
        tax_adjustments = item.adjustments.select(&:tax?)
        # Tax adjustments come in not one but *two* exciting flavours:
        # Included & additional

        # Included tax adjustments are those which are included in the price.
        # These ones should not affect the eventual total price.
        #
        # Additional tax adjustments are the opposite, affecting the final total.
        item.included_tax_total   = tax_adjustments.select(&:included?).sum(&:amount)
        item.additional_tax_total = tax_adjustments.reject(&:included?).sum(&:amount)
      end
    end

    def update_cancellations
      line_items.each do |line_item|
        line_item.adjustments.select(&:cancellation?).each(&:recalculate)
      end
    end

    def update_item_totals
      [*line_items, *shipments].each do |item|
        # The cancellation_total isn't persisted anywhere but is included in
        # the adjustment_total
        item.adjustment_total = item.adjustments.
          select(&:eligible?).
          reject(&:included?).
          sum(&:amount)

        if item.changed?
          item.update_columns(
            promo_total:          item.promo_total,
            included_tax_total:   item.included_tax_total,
            additional_tax_total: item.additional_tax_total,
            adjustment_total:     item.adjustment_total,
            updated_at:           Time.current,
          )
        end
      end
    end
  end
end

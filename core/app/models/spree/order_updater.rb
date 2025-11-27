# frozen_string_literal: true

module Spree
  class OrderUpdater
    attr_reader :order
    delegate :payments, :line_items, :adjustments, :all_adjustments, :shipments, :quantity, to: :order

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
    def recalculate
      order.transaction do
        recalculate_item_count
        update_shipment_amounts
        update_totals
        if order.completed?
          recalculate_payment_state
          update_shipments
          recalculate_shipment_state
        end
        Spree::Bus.publish(:order_recalculated, order:)
        persist_totals
      end
    end
    alias_method :update, :recalculate
    deprecate update: :recalculate, deprecator: Spree.deprecator

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
    def recalculate_shipment_state
      log_state_change('shipment') do
        order.shipment_state = determine_shipment_state
      end

      order.shipment_state
    end
    alias_method :update_shipment_state, :recalculate_shipment_state
    deprecate update_shipment_state: :recalculate_shipment_state, deprecator: Spree.deprecator

    # Recalculates the +payment_state+ attribute according to the following logic:
    #
    # paid          when +payment_total+ is equal to +total+
    # balance_due   when +payment_total+ is less than +total+
    # credit_owed   when +payment_total+ is greater than +total+
    # failed        when most recent payment is in the failed state
    # void          when the order has been canceled and the payment total is 0
    #
    # The +payment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
    def recalculate_payment_state
      log_state_change('payment') do
        order.payment_state = determine_payment_state
      end

      order.payment_state
    end
    alias_method :update_payment_state, :recalculate_payment_state
    deprecate update_payment_state: :recalculate_payment_state, deprecator: Spree.deprecator

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
    def update_adjustments
      # Promotion adjustments must be applied first, then tax adjustments.
      # This fits the criteria for VAT tax as outlined here:
      # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
      # It also fits the criteria for sales tax as outlined here:
      # http://www.boe.ca.gov/formspubs/pub113/
      update_promotions
      update_tax_adjustments
      recalculate_item_totals
    end
    alias_method :recalculate_adjustments, :update_adjustments
    deprecate recalculate_adjustments: :update_adjustments, deprecator: Spree.deprecator

    # Updates the following Order total values:
    #
    # +payment_total+      The total value of all finalized Payments (NOTE: non-finalized Payments are excluded)
    # +item_total+         The total value of all LineItems
    # +adjustment_total+   The total value of all adjustments (promotions, credits, etc.)
    # +promo_total+        The total value of all promotion adjustments
    # +total+              The so-called "order total."  This is equivalent to +item_total+ plus +adjustment_total+.
    def update_totals
      recalculate_payment_total
      recalculate_item_total
      recalculate_shipment_total
      update_adjustment_total
    end

    def update_shipment_amounts
      shipments.each(&:update_amounts)
    end

    # give each of the shipments a chance to update themselves
    def update_shipments
      shipments.each(&:update_state)
    end

    def recalculate_payment_total
      order.payment_total = payments.completed.includes(:refunds).sum { |payment| payment.amount - payment.refunds.sum(:amount) }
    end
    alias_method :update_payment_total, :recalculate_payment_total
    deprecate update_payment_total: :recalculate_payment_total, deprecator: Spree.deprecator

    def recalculate_shipment_total
      order.shipment_total = shipments.to_a.sum(&:cost)
      recalculate_order_total
    end
    alias_method :update_shipment_total, :recalculate_shipment_total
    deprecate update_shipment_total: :recalculate_shipment_total, deprecator: Spree.deprecator

    def recalculate_order_total
      order.total = order.item_total + order.shipment_total + order.adjustment_total
    end
    alias_method :update_order_total, :recalculate_order_total
    deprecate update_order_total: :recalculate_order_total, deprecator: Spree.deprecator

    def update_adjustment_total
      update_adjustments

      all_items = (line_items + shipments).reject(&:marked_for_destruction?)
      # Ignore any adjustments that have been marked for destruction in our
      # calculations. They'll get removed when/if we persist the order.
      valid_adjustments = adjustments.reject(&:marked_for_destruction?)
      order_tax_adjustments = valid_adjustments.select(&:tax?)

      order.adjustment_total = all_items.sum(&:adjustment_total) + valid_adjustments.sum(&:amount)
      order.included_tax_total = all_items.sum(&:included_tax_total) + order_tax_adjustments.select(&:included?).sum(&:amount)
      order.additional_tax_total = all_items.sum(&:additional_tax_total) + order_tax_adjustments.reject(&:included?).sum(&:amount)

      recalculate_order_total
    end

    def recalculate_item_count
      order.item_count = line_items.to_a.sum(&:quantity)
    end
    alias_method :update_item_count, :recalculate_item_count
    deprecate update_item_count: :recalculate_item_count, deprecator: Spree.deprecator

    def recalculate_item_total
      order.item_total = line_items.to_a.sum(&:amount)
      recalculate_order_total
    end
    alias_method :update_item_total, :recalculate_item_total
    deprecate update_item_total: :recalculate_item_total, deprecator: Spree.deprecator

    def persist_totals
      order.save!
    end

    def log_state_change(name)
      state = "#{name}_state"
      old_state = order.public_send(state)
      yield
      new_state = order.public_send(state)
      if old_state != new_state
        StateChangeTrackingJob.perform_later(
          order,
          old_state,
          new_state,
          Time.current,
          name
        )
      end
    end

    def update_promotions
      Spree::Config.promotions.order_adjuster_class.new(order).call
    end

    def update_tax_adjustments
      Spree::Config.tax_adjuster_class.new(order).adjust!
    end

    def update_cancellations
    end
    deprecate :update_cancellations, deprecator: Spree.deprecator

    def recalculate_item_totals
      [*line_items, *shipments].each do |item|
        Spree::Config.item_total_class.new(item).recalculate!

        next unless item.changed?

        item.assign_attributes(
          promo_total:          item.promo_total,
          included_tax_total:   item.included_tax_total,
          additional_tax_total: item.additional_tax_total,
          adjustment_total:     item.adjustment_total
        )
      end
    end
  end
end

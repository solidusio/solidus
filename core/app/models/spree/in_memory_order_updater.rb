# frozen_string_literal: true

require "spree/manipulative_query_monitor"

module Spree
  class InMemoryOrderUpdater
    attr_reader :order

    # when true, +recalculate+ logs a warning for manipulative queries (INSERT,
    # UPDATE or DELETE) made before the order is saved. When persisting, queries
    # made while updating the totals are exempt.
    class_attribute :log_manipulative_queries
    self.log_manipulative_queries = true

    delegate :payments, :line_items, :adjustments, :all_adjustments, :shipments, :quantity, to: :order

    def initialize(order)
      @order = order
    end

    # This is a multi-purpose method for processing logic related to changes in the Order.
    # It is meant to be called from various observers so that the Order is aware of changes
    # that affect totals and other values stored in the Order.
    #
    # The recalculation runs in a transaction. Unless +persist+ is false, it
    # ends by saving the Order, and after that the +order_recalculated+ event is
    # published. Do not call this method from Order save callbacks or
    # +order_recalculated+ subscribers, as that would recurse.
    def recalculate(persist: true)
      monitor =
        if log_manipulative_queries
          Spree::ManipulativeQueryMonitor
        else
          proc { |&block| block.call }
        end

      order.transaction do
        monitor.call do
          recalculate_line_item_prices
          recalculate_item_count
          assign_shipment_amounts
        end

        if persist
          update_totals(persist:)
        else
          monitor.call do
            update_totals(persist:)
          end
        end

        monitor.call do
          if order.completed?
            recalculate_payment_state
            recalculate_shipment_state
          end
        end

        persist_totals if persist
      end

      Spree::Bus.publish(:order_recalculated, order:) if persist
    end
    alias_method :update, :recalculate
    deprecate update: :recalculate, deprecator: Spree.deprecator

    # Recalculates the state on all of the shipments, then recalculates the
    # +shipment_state+ attribute according to the following logic,
    # using the first rule that matches:
    #
    # backorder when any Shipment has a backordered InventoryUnit
    # partial   when the Shipments are not all in the same state, which most likely means the Order is partially shipped
    #
    # Otherwise it is the state that all Shipments share (e.g. "pending", "ready"
    # or "shipped"), or nil when there are no Shipments.
    #
    # The +shipment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
    def recalculate_shipment_state
      shipments.each(&:recalculate_state)

      order.shipment_state = determine_shipment_state
      order.shipment_state
    end
    alias_method :update_shipment_state, :recalculate_shipment_state
    deprecate update_shipment_state: :recalculate_shipment_state, deprecator: Spree.deprecator

    # Recalculates the +payment_state+ attribute according to the following logic,
    # using the first rule that matches:
    #
    # failed        when there are payments, all of them failed, invalid or void, and +outstanding_balance+ is not 0
    # void          when the order has been canceled and the payment total is 0
    # balance_due   when +outstanding_balance+ is greater than 0
    # credit_owed   when +outstanding_balance+ is less than 0
    # paid          when +outstanding_balance+ is 0
    #
    # The +payment_state+ value helps with reporting, etc. since it provides a quick and easy way to locate Orders needing attention.
    def recalculate_payment_state
      order.payment_state = determine_payment_state
      order.payment_state
    end
    alias_method :update_payment_state, :recalculate_payment_state
    deprecate update_payment_state: :recalculate_payment_state, deprecator: Spree.deprecator

    private

    def determine_payment_state
      if payments.present? && payments.valid.empty? && order.outstanding_balance != 0
        "failed"
      elsif order.state == "canceled" && order.payment_total.zero?
        "void"
      elsif order.outstanding_balance > 0
        "balance_due"
      elsif order.outstanding_balance < 0
        "credit_owed"
      else
        # outstanding_balance == 0
        "paid"
      end
    end

    def determine_shipment_state
      if order.backordered?
        "backorder"
      else
        # get all the shipment states for this order
        shipment_states = shipments.states
        if shipment_states.size > 1
          # multiple shipment states means it's most likely partially shipped
          "partial"
        else
          # will return nil if no shipments are found
          shipment_states.first
        end
      end
    end

    # This will run the promotion adjuster, then the tax adjuster, and then
    # update the total fields (included_tax_total, additional_tax_total, and
    # adjustment_total) on every line item and shipment. Promotion systems may
    # change how those totals are computed, as solidus_legacy_promotions does.
    # @return [void]
    def update_adjustments(persist:)
      # Promotion adjustments must be applied first, then tax adjustments.
      # This fits the criteria for VAT tax as outlined here:
      # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
      # It also fits the criteria for sales tax as outlined here:
      # http://www.boe.ca.gov/formspubs/pub113/
      update_promotions(persist:)
      update_tax_adjustments
      assign_item_totals
    end

    # Updates the following Order total values:
    #
    # +payment_total+      The total value of all completed Payments, minus their Refunds
    # +item_total+         The total value of all LineItems
    # +shipment_total+     The total cost of all Shipments
    # +adjustment_total+   By default, the +adjustment_total+ of all LineItems and Shipments, plus the Order's own adjustments
    # +total+              The so-called "order total."  This is equivalent to +item_total+ plus +shipment_total+ plus +adjustment_total+.
    #
    # The tax totals (+included_tax_total+ and +additional_tax_total+) are updated
    # too. +promo_total+ is not computed by the updater itself, but by the
    # promotion adjuster that this method runs.
    def update_totals(persist:)
      recalculate_payment_total
      recalculate_item_total
      recalculate_shipment_total
      update_adjustment_total(persist:)
    end

    def assign_shipment_amounts
      shipments.each(&:assign_amounts)
    end

    def update_adjustment_total(persist:)
      update_adjustments(persist:)

      all_items = line_items + shipments
      # Ignore any adjustments that have been marked for destruction in our
      # calculations. They'll get removed when/if we persist the order.
      valid_adjustments = adjustments.reject(&:marked_for_destruction?)
      order_tax_adjustments = valid_adjustments.select(&:tax?)

      order.adjustment_total = all_items.sum(&:adjustment_total) + valid_adjustments.sum(&:amount)
      order.included_tax_total = all_items.sum(&:included_tax_total) + order_tax_adjustments.select(&:included?).sum(&:amount)
      order.additional_tax_total = all_items.sum(&:additional_tax_total) + order_tax_adjustments.reject(&:included?).sum(&:amount)

      recalculate_order_total
    end

    def update_promotions(persist:)
      Spree::Config.promotions.order_adjuster_class.new(order).call(persist:)
    end

    def update_tax_adjustments
      Spree::Config.tax_adjuster_class.new(order).adjust!
    end

    def update_cancellations
    end
    deprecate :update_cancellations, deprecator: Spree.deprecator

    def assign_item_totals
      [*line_items, *shipments].each do |item|
        Spree::Config.item_total_class.new(item).recalculate!

        next unless item.changed?

        item.assign_attributes(
          promo_total: item.promo_total,
          included_tax_total: item.included_tax_total,
          additional_tax_total: item.additional_tax_total,
          adjustment_total: item.adjustment_total
        )
      end
    end

    def recalculate_payment_total
      order.payment_total = payments.completed.includes(:refunds).sum { |payment| payment.amount - payment.refunds.sum(:amount) }
    end

    def recalculate_shipment_total
      order.shipment_total = shipments.to_a.sum(&:cost)
      recalculate_order_total
    end

    def recalculate_order_total
      order.total = order.item_total + order.shipment_total + order.adjustment_total
    end

    def recalculate_item_count
      order.item_count = line_items.to_a.sum(&:quantity)
    end

    def recalculate_item_total
      order.item_total = line_items.to_a.sum(&:amount)
      recalculate_order_total
    end

    def recalculate_line_item_prices
      if Spree::Config.recalculate_cart_prices
        line_items.each(&:recalculate_price)
      end
    end

    def persist_totals
      log_state_change("payment")
      log_state_change("shipment")
      order.save!
    end

    def log_state_change(name)
      state = "#{name}_state"
      previous_state, current_state = order.changes[state]

      if previous_state != current_state
        # Enqueue the job to track this state change
        StateChangeTrackingJob.perform_later(
          order,
          previous_state,
          current_state,
          Time.current,
          name
        )
      end
    end
  end
end

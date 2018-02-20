# frozen_string_literal: true

module Spree
  # Spree::OrderMerger is responsible for taking two orders and merging them
  # together by adding the line items from additional orders to the order
  # that the OrderMerger is initialized with.
  #
  # Orders that are merged should be incomplete orders which should belong to
  # the same user. They should also be in the same currency.
  class OrderMerger
    # @!attribute order
    #   @api public
    #   @return [Spree::Order] The order which items wll be merged into.
    attr_accessor :order

    delegate :updater, to: :order

    # Create the OrderMerger
    #
    # @api public
    # @param [Spree::Order] order The order which line items will be merged
    # into.
    def initialize(order)
      @order = order
    end

    # Merge a second order in to the order the OrderMerger was initialized with
    #
    # The line items from `other_order` will be merged in to the `order` for
    # this OrderMerger object. If the line items are for the same variant, it
    # will add the quantity of the incoming line item to the existing line item.
    # Otherwise, it will assign the line item to the new order.
    #
    # After the orders have been merged the `other_order` will be destroyed.
    #
    # @example
    #   initial_order = Spree::Order.find(1)
    #   order_to_merge = Spree::Order.find(2)
    #   merger = Spree::OrderMerger.new(initial_order)
    #   merger.merge!(order_to_merge)
    #   # order_to_merge is destroyed, initial order now contains the line items
    #   # of order_to_merge
    #
    # @api public
    # @param [Spree::Order] other_order An order which will be merged in to the
    # order the OrderMerger was initialized with.
    # @param [Spree::User] user Associate the order the user specified. If not
    # specified, the order user association will not be changed.
    # @return [void]
    def merge!(other_order, user = nil)
      if other_order.currency == order.currency
        other_order.line_items.each do |other_order_line_item|
          current_line_item = find_matching_line_item(other_order_line_item)
          handle_merge(current_line_item, other_order_line_item)
        end
      end

      set_user(user)
      persist_merge

      # So that the destroy doesn't take out line items which may have been re-assigned
      other_order.line_items.reload
      other_order.destroy
    end

    private

    # Retreive a matching line item from the existing order
    #
    # It will compare line items based on variants, and all line item
    # comparison hooks on the order.
    #
    # @api private
    # @param [Spree::LineItem] other_order_line_item The line item from
    # `other_order` we are attempting to merge in.
    # @return [Spree::LineItem] A matching line item from the order. nil if none
    # exist.
    def find_matching_line_item(other_order_line_item)
      order.line_items.detect do |my_li|
        my_li.variant == other_order_line_item.variant &&
          order.line_item_comparison_hooks.all? do |hook|
            order.send(hook, my_li, other_order_line_item.serializable_hash)
          end
      end
    end

    # Associate the user with the order
    #
    # @api private
    # @param [Spree::User] user The user to associate with the order. If nil
    # the order user association will remain the same. If the order is already
    # associated with a user, it will not be changed.
    # @return [void]
    def set_user(user)
      order.associate_user!(user) if !order.user && user
    end

    # Merge the `other_order_line_item` into `current_line_item`
    #
    # If `current_line_item` is nil, the `other_order_line_item` will be
    # re-assigned to the `order`.
    #
    # If the merged line item can not be saved, an error will be added to
    # `order`.
    #
    # @api private
    # @param [Spree::LineItem] current_line_item The line item to be merged
    # into. If nil, the `other_order_line_item` will be re-assigned.
    # @param [Spree::LineItem] other_order_line_item The line item to merge in.
    # @return [void]
    def handle_merge(current_line_item, other_order_line_item)
      if current_line_item
        current_line_item.quantity += other_order_line_item.quantity
        handle_error(current_line_item) unless current_line_item.save
      else
        order.line_items << other_order_line_item
        handle_error(other_order_line_item) unless other_order_line_item.save
      end
    end

    # Handle an error from saving the `line_item`
    #
    # This adds errors from the line item to the `errors[:base]` of the order.
    #
    # @api private
    # @param [Spree::LineItem] line_item The line item which could not be saved
    # @return [void]
    def handle_error(line_item)
      order.errors[:base] << line_item.errors.full_messages
    end

    # Save the order totals after merge
    #
    # It triggers the order updater to ensure that item counts and totals are
    # up to date.
    #
    # @api private
    # @return [void]
    def persist_merge
      updater.update
    end
  end
end

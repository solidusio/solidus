module Spree
  class OrderContents
    attr_accessor :order

    def initialize(order)
      @order = order
    end

    # Add a line items to the order if there is inventory to do so
    # and populate Promotions
    #
    # @params [Spree::Variant] :variant The variant the line_item should
    #   be associated with
    # @params [Integer] :quantity The line_item quantity
    # @param [Hash] :options Options for the adding proccess
    #   Valid options:
    #     shipment: [Spree::Shipment] LineItem target shipment
    #     stock_location_quantities:
    #       stock_location_id: The stock location to source from
    #
    # @return [Spree::LineItem]
    def add(variant, quantity = 1, options = {})
      line_item = add_to_line_item(variant, quantity, options)
      after_add_or_remove(line_item, options)
    end

    def remove(variant, quantity = 1, options = {})
      line_item = remove_from_line_item(variant, quantity, options)
      after_add_or_remove(line_item, options)
    end

    def remove_line_item(line_item, options = {})
      order.line_items.destroy(line_item)
      after_add_or_remove(line_item, options)
    end

    def update_cart(params)
      if order.update_attributes(params)
        unless order.completed?
          order.line_items = order.line_items.select { |li| li.quantity > 0 }
          # Update totals, then check if the order is eligible for any cart promotions.
          # If we do not update first, then the item total will be wrong and ItemTotal
          # promotion rules would not be triggered.
          reload_totals
          PromotionHandler::Cart.new(order).activate
          order.ensure_updated_shipments
        end
        reload_totals
        true
      else
        false
      end
    end

    def advance
      while @order.next; end
    end

    def approve(user: nil, name: nil)
      if user.blank? && name.blank?
        raise ArgumentError, 'user or name must be specified'
      end

      order.update_attributes!(
        approver: user,
        approver_name: name,
        approved_at: Time.current
      )
    end

    private

    def after_add_or_remove(line_item, options = {})
      reload_totals
      shipment = options[:shipment]
      shipment.present? ? shipment.update_amounts : order.ensure_updated_shipments
      PromotionHandler::Cart.new(order, line_item).activate
      reload_totals
      line_item
    end

    def order_updater
      @updater ||= OrderUpdater.new(order)
    end

    def reload_totals
      order_updater.update
    end

    def add_to_line_item(variant, quantity, options = {})
      line_item = grab_line_item_by_variant(variant, false, options)

      line_item ||= order.line_items.new(
        quantity: 0,
        variant: variant,
      )

      line_item.quantity += quantity.to_i
      line_item.options = ActionController::Parameters.new(options).permit(PermittedAttributes.line_item_attributes).to_h

      if line_item.new_record?
        create_order_stock_locations(line_item, options[:stock_location_quantities])
      end

      line_item.target_shipment = options[:shipment]
      line_item.save!
      line_item
    end

    def remove_from_line_item(variant, quantity, options = {})
      line_item = grab_line_item_by_variant(variant, true, options)
      line_item.quantity -= quantity
      line_item.target_shipment = options[:shipment]

      if line_item.quantity == 0
        order.line_items.destroy(line_item)
      else
        line_item.save!
      end

      line_item
    end

    def grab_line_item_by_variant(variant, raise_error = false, options = {})
      line_item = order.find_line_item_by_variant(variant, options)

      if !line_item.present? && raise_error
        raise ActiveRecord::RecordNotFound, "Line item not found for variant #{variant.sku}"
      end

      line_item
    end

    def create_order_stock_locations(line_item, stock_location_quantities)
      return unless stock_location_quantities.present?
      order = line_item.order
      stock_location_quantities.each do |stock_location_id, quantity|
        order.order_stock_locations.create!(stock_location_id: stock_location_id, quantity: quantity, variant_id: line_item.variant_id) unless quantity.to_i.zero?
      end
    end
  end
end

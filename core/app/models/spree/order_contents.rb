module Spree
  class OrderContents
    attr_accessor :order, :currency

    def initialize(order)
      @order = order
    end

    def add(variant, quantity = 1, currency = nil, shipment = nil)
      line_item = add_to_line_item(variant, quantity, currency, shipment)
      reload_totals
      shipment.present? ? shipment.update_amounts : order.ensure_updated_shipments
      PromotionHandler::Cart.new(order, line_item).activate
      ItemAdjustments.new(line_item).update
      reload_totals
      line_item
    end

    def remove(variant, quantity = 1, shipment = nil)
      line_item = remove_from_line_item(variant, quantity, shipment)
      reload_totals
      shipment.present? ? shipment.update_amounts : order.ensure_updated_shipments
      PromotionHandler::Cart.new(order, line_item).activate
      ItemAdjustments.new(line_item).update
      reload_totals
      line_item
    end

    def update_cart(params)
      if order.update_attributes(params)
        order.line_items = order.line_items.select {|li| li.quantity > 0 }
        # Update totals, then check if the order is eligible for any cart promotions.
        # If we do not update first, then the item total will be wrong and ItemTotal
        # promotion rules would not be triggered.
        reload_totals
        PromotionHandler::Cart.new(order).activate
        order.ensure_updated_shipments
        reload_totals
        true
      else
        false
      end
    end

    # NOTE I'm not sure that override_email is necessary,
    # let's look into removing it at some point.
    #
    # -AT 01/27/2015
    def associate_user(user, override_email = true)
      return unless user
      order.user = user
      order.email = user.email if !order.email || override_email
      order.created_by ||= user

      ###
      # TODO ideally we would fix up how we deal with persistence here, but
      # this is current behavior that seems worth maintaining for now (at least
      # based on specs).
      #
      # -AT 01/27/2015
      if order.persisted?
        order.save!

        reload_totals
        PromotionHandler::Cart.new(order).activate
        reload_totals
      end
      true
    end

    def merge(other_order, user: nil)
      other_order.line_items.each do |line_item|
        next unless line_item.currency == order.currency
        current_line_item = order.line_items.find_by(variant: line_item.variant)
        if current_line_item
          current_line_item.quantity += line_item.quantity
          current_line_item.save
        else
          line_item.order_id = order.id
          line_item.save
        end
      end

      # TODO: Call this class's `associate_user' method after it's merged in
      order.associate_user!(user) if order.user.nil? && user

      order.updater.update_item_count
      order.update!

      # So that the destroy doesn't take out line items which may have been re-assigned
      other_order.line_items.reload
      other_order.destroy
    end

    # TODO: It would be nice to remove this from Spree::Order except that it's
    # part of the state_machine definition.  We should think about the best ways
    # to replace external code hooking directly into state_machine & etc.
    def cancel
      order.cancel!
    end

    def advance
      while @order.next; end
    end

    private
      def order_updater
        @updater ||= OrderUpdater.new(order)
      end

      def reload_totals
        order_updater.update_item_count
        order_updater.update
        order.reload
      end

      def add_to_line_item(variant, quantity, currency=nil, shipment=nil)
        line_item = grab_line_item_by_variant(variant)

        if line_item
          line_item.target_shipment = shipment
          line_item.quantity += quantity.to_i
          line_item.currency = currency unless currency.nil?
        else
          line_item = order.line_items.new(quantity: quantity, variant: variant)
          line_item.target_shipment = shipment
          if currency
            line_item.currency = currency
            line_item.price    = variant.price_in(currency).amount
          else
            line_item.price    = variant.price
          end
        end

        line_item.save!
        line_item
      end

      def remove_from_line_item(variant, quantity, shipment=nil)
        line_item = grab_line_item_by_variant(variant, true)
        line_item.quantity += -quantity
        line_item.target_shipment= shipment

        if line_item.quantity == 0
          line_item.destroy
        else
          line_item.save!
        end

        line_item
      end

      def grab_line_item_by_variant(variant, raise_error = false)
        line_item = order.find_line_item_by_variant(variant)

        if !line_item.present? && raise_error
          raise ActiveRecord::RecordNotFound, "Line item not found for variant #{variant.sku}"
        end

        line_item
      end
  end
end

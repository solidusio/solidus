module Spree
  class UnreturnedItemCharger
    class ChargeFailure < StandardError
      attr_accessor :new_order
      def initialize(message, new_order)
        @new_order = new_order
        super(message)
      end
    end

    class_attribute :failure_handler

    attr_reader :original_order

    def initialize(shipment, return_items)
      @shipment = shipment
      @original_order = @shipment.order
      @return_items = return_items
    end

    def charge_for_items
      new_order.contents.associate_user(@original_order.user) if @original_order.user

      add_exchange_variants_to_order

      new_order.reload.update!
      while new_order.state != new_order.checkout_steps[-2] && new_order.next; end

      set_order_payment

      # the order builds a shipment on its own on transition to delivery, but we want
      # the original exchange shipment, not the built one
      set_shipment_for_new_order

      new_order.contents.approve(name: self.class.name)
      new_order.reload.complete!

      if !new_order.completed?
        raise ChargeFailure.new('order not complete', new_order)
      elsif !new_order.valid?
        raise ChargeFailure.new('order not valid', new_order)
      end
    end

    private

    def new_order
      @new_order ||= Spree::Order.create!(exchange_order_attributes)
    end

    def add_exchange_variants_to_order
      @return_items.group_by(&:exchange_variant).map do |variant, variant_return_items|
        variant_inventory_units = variant_return_items.map(&:exchange_inventory_unit)
        line_item = Spree::LineItem.create!(variant: variant, quantity: variant_return_items.count, order: new_order)
        variant_inventory_units.each { |i| i.update_attributes!(line_item_id: line_item.id, order_id: new_order.id) }
      end
    end

    def set_shipment_for_new_order
      new_order.shipments.destroy_all
      @shipment.update_attributes!(order_id: new_order.id)
      new_order.update_attributes!(state: "confirm")
    end

    def set_order_payment
      unless new_order.payments.present?
        card_to_reuse = @original_order.valid_credit_cards.first
        card_to_reuse = @original_order.user.credit_cards.default.first if !card_to_reuse && @original_order.user
        Spree::Payment.create!(order: new_order,
                               payment_method_id: card_to_reuse.try(:payment_method_id),
                               source: card_to_reuse,
                               amount: new_order.total)
      end
    end

    def exchange_order_attributes
      order_attributes = {
        bill_address: @original_order.bill_address,
        ship_address: @original_order.ship_address,
        email: @original_order.email
      }
      order_attributes[:store_id] = @original_order.store_id if @original_order.respond_to?(:store_id)
      order_attributes
    end
  end
end

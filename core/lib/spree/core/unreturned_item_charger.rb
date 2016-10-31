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

    attr_reader :original_order, :new_order

    def initialize(shipment, return_items)
      @shipment = shipment
      @original_order = @shipment.order
      @return_items = return_items
    end

    def charge_for_items
      self.new_order = Spree::Order.create!(exchange_order_attributes)

      new_order.associate_user!(@original_order.user) if @original_order.user

      add_exchange_variants_to_order
      set_shipment_for_new_order

      new_order.update!
      set_order_payment

      # There are several checks in the order state machine to skip
      # certain transitions when an order is an unreturned exchange
      if !new_order.unreturned_exchange?
        raise ChargeFailure.new('order is not an unreturned exchange', new_order)
      end

      # Transitions will call update_totals on the order
      until new_order.can_complete?
        new_order.next!
      end

      new_order.contents.approve(name: self.class.name)
      new_order.complete!
      Spree::OrderCapturing.new(new_order).capture_payments if Spree::Config[:auto_capture_exchanges] && !Spree::Config[:auto_capture]

      @return_items.each(&:expired!)
      create_new_rma if Spree::Config[:create_rma_for_unreturned_exchange]

      if !new_order.completed?
        raise ChargeFailure.new('order not complete', new_order)
      elsif !new_order.valid?
        raise ChargeFailure.new('order not valid', new_order)
      end
    end

    private

    attr_writer :new_order

    def add_exchange_variants_to_order
      @return_items.group_by(&:exchange_variant).map do |variant, variant_return_items|
        variant_inventory_units = variant_return_items.map(&:exchange_inventory_unit)
        line_item = Spree::LineItem.create!(variant: variant, quantity: variant_return_items.count, order: new_order)
        variant_inventory_units.each { |i| i.update_attributes!(line_item_id: line_item.id, order_id: new_order.id) }
      end
    end

    def set_shipment_for_new_order
      @shipment.update_attributes!(order_id: new_order.id)
      new_order.shipments.reset
    end

    def set_order_payment
      unless new_order.payments.present?
        card_to_reuse = @original_order.valid_credit_cards.first
        card_to_reuse = @original_order.user.credit_cards.default.first if !card_to_reuse && @original_order.user
        new_order.payments.create!(
          payment_method_id: card_to_reuse.try(:payment_method_id),
          source: card_to_reuse,
          amount: new_order.total
        )
      end
    end

    def create_new_rma
      @return_items.group_by(&:return_authorization).each do |rma, return_items|
        new_return_items = return_items.map { |ri| Spree::ReturnItem.create!(inventory_unit: ri.inventory_unit) }
        Spree::ReturnAuthorization.create!(order: rma.order,
                                           reason: rma.reason,
                                           stock_location: rma.stock_location,
                                           return_items: new_return_items)
      end
    end

    def exchange_order_attributes
      {
        bill_address: @original_order.bill_address,
        ship_address: @original_order.ship_address,
        email: @original_order.email,
        store_id: @original_order.store_id,
        frontend_viewable: false
      }
    end
  end
end

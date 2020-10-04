# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/order_factory'

RSpec.shared_examples "shipping methods are assigned" do
  context "given a shipping method" do
    let(:shipping_method) { create(:shipping_method) }

    it "assigns the shipping method when created" do
      expect(
        create(
          factory,
          shipping_method: shipping_method
        ).shipments.map(&:shipping_method)
      ).to all(eq(shipping_method))
    end

    it "assigns the shipping method when built" do
      expect(
        build(
          factory,
          shipping_method: shipping_method
        ).shipments.map(&:shipping_method)
      ).to all(eq(shipping_method))
    end
  end
end

RSpec.shared_examples "an order with line items factory" do |expected_order_state, expected_inventory_unit_state|
  # This factory cannot be built correctly because Shipment#set_up_inventory
  # requires records to be saved.
  context "when created" do
    let(:stock_location) { create(:stock_location) }
    let(:first_variant) { create(:variant) }
    let(:second_variant) { create(:variant) }
    let(:shipping_method) { create(:shipping_method) }
    let(:order) do
      create(
        factory,
        stock_location: stock_location,
        line_items_attributes: [
          { variant: first_variant, quantity: 1, price: 1 },
          { variant: second_variant, quantity: 2, price: 2 }
        ],
        shipment_cost: 3,
        shipping_method: shipping_method
      )
    end

    it "has the expected attributes" do
      aggregate_failures "for line items" do
        expect(order.line_items.count).to eq 2
        expect(order.line_items[0]).to have_attributes(
          quantity: 1,
          price: 1.0
        )
        expect(order.line_items[1]).to have_attributes(
          price: 2.0,
          quantity: 2
        )
      end

      aggregate_failures "for shipments" do
        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          amount: 3.0,
          stock_location: stock_location
        )

        expect(order.shipments[0].shipping_method).to eq(shipping_method)

        # Explicitly order by line item id, because otherwise these can be in
        # an arbitrary order.
        inventory_units = order.shipments[0].inventory_units.sort_by(&:line_item_id)

        expect(inventory_units.count).to eq(3)
        expect(inventory_units[0]).to have_attributes(
          order: order,
          shipment: order.shipments[0],
          line_item: order.line_items[0],
          variant: order.line_items[0].variant,
          state: expected_inventory_unit_state
        )
        expect(inventory_units[1]).to have_attributes(
          order: order,
          shipment: order.shipments[0],
          line_item: order.line_items[1],
          variant: order.line_items[1].variant,
          state: expected_inventory_unit_state
        )
        expect(inventory_units[2]).to have_attributes(
          order: order,
          shipment: order.shipments[0],
          line_item: order.line_items[1],
          variant: order.line_items[1].variant,
          state: expected_inventory_unit_state
        )
      end

      expect(order).to have_attributes(
        item_total: 5.0,
        ship_total: 3.0,
        total: 8.0,
        state: expected_order_state
      )
    end
  end

  context 'when shipments should be taxed' do
    let!(:ship_address) { create(:address) }
    let!(:tax_zone) { create(:global_zone) } # will include the above address
    let!(:tax_rate) { create(:tax_rate, amount: 0.10, zone: tax_zone, tax_categories: [tax_category]) }

    let(:tax_category) { create(:tax_category) }
    let(:shipping_method) { create(:shipping_method, tax_category: tax_category, zones: [tax_zone]) }

    it 'shipments get a tax adjustment' do
      order = create(factory, ship_address: ship_address, shipping_method: shipping_method)
      shipment = order.shipments[0]

      expect(shipment.additional_tax_total).to be > 0
    end
  end
end
RSpec.describe 'order factory' do
  let(:factory_class) { Spree::Order }

  describe 'plain order' do
    let(:factory) { :order }

    it_behaves_like 'a working factory'

    shared_examples "it has the expected attributes" do
      it do
        aggregate_failures do
          expect(order.bill_address).to be_present
          expect(order.ship_address).to be_present
          expect(order.user).to be_present
          expect(order.email).to be_present
          expect(order.email).to eq(order.user.email)
          expect(order.state).to eq "cart"
          expect(order.store).to be_present
          expect(order).not_to be_completed
        end
      end
    end

    context "when built" do
      let(:order) { build(factory) }
      it_behaves_like "it has the expected attributes"
    end

    context "when created" do
      let(:order) { create(factory) }
      it_behaves_like "it has the expected attributes"
    end
  end

  describe 'order with totals' do
    let(:factory) { :order_with_totals }

    it_behaves_like 'a working factory'

    context "when built" do
      let(:order) { build(factory, line_items_price: 77) }

      it "has all the expected attributes but total" do
        aggregate_failures do
          expect(order.total).to eq 0
          expect(order.line_items.length).to eq 1
          expect(order.line_items.first.price).to eq 77
        end
      end
    end

    context "when created" do
      let(:order) { create(factory, line_items_price: 77) }

      it "has the expected attributes" do
        aggregate_failures do
          expect(order.total).to eq order.line_items.sum(&:total)
          expect(order.line_items.length).to eq 1
          expect(order.line_items.first.price).to eq 77
        end
      end
    end
  end

  describe 'order with line items' do
    let(:factory) { :order_with_line_items }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "cart", "on_hand"
    it_behaves_like 'shipping methods are assigned'
  end

  describe 'completed order with promotion' do
    let(:factory) { :completed_order_with_promotion }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to be_complete

        expect(order.order_promotions.count).to eq(1)
        order_promotion = order.order_promotions[0]
        expect(order_promotion.promotion_code.promotion).to eq order_promotion.promotion
      end
    end

    context 'with a promotion with an action' do
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }
      it "has the expected attributes" do
        order = create(factory, promotion: promotion)
        aggregate_failures do
          expect(order).to be_completed
          expect(order).to be_complete

          expect(order.line_items[0].adjustments.count).to eq 1
          adjustment = order.line_items[0].adjustments[0]
          expect(adjustment).to have_attributes(
            amount: -10,
            eligible: true,
            order_id: order.id
          )
        end
      end
    end
  end

  describe 'order ready to complete' do
    let(:factory) { :order_ready_to_complete }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "confirm", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "is completable" do
      order = create(factory)

      expect { order.complete! }.to change {
        order.complete?
      }.from(false).to(true)
    end
  end

  describe 'completed order with totals' do
    let(:factory) { :completed_order_with_totals }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          item_total: 10,
          ship_total: 100,
          total: 110,
          state: 'complete'
        )
        expect(order.inventory_units.where(pending: true)).to be_empty
        expect(order.inventory_units.where(pending: false)).to_not be_empty
      end
    end
  end

  describe 'completed order with pending payment' do
    let(:factory) { :completed_order_with_pending_payment }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          payment_state: 'balance_due',
          total: 110,
          payment_total: 0 # payment is still pending
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'pending'
        )
      end
    end
  end

  describe 'order ready to ship' do
    let(:factory) { :order_ready_to_ship }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "on_hand"
    it_behaves_like 'shipping methods are assigned'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          total: 110,
          payment_total: 110,
          payment_state: "paid",
          shipment_state: "ready"
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'completed'
        )

        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          state: 'ready'
        )
      end
    end

    it "can be shipped" do
      order = create(factory)
      order.shipments[0].ship
      aggregate_failures do
        expect(order.shipment_state).to eq "shipped"
        expect(order.shipments[0]).to be_shipped
      end
    end
  end

  describe 'shipped order' do
    let(:factory) { :shipped_order }

    it_behaves_like 'a working factory'
    it_behaves_like 'an order with line items factory', "complete", "shipped"
    it_behaves_like 'shipping methods are assigned'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          total: 110,
          payment_total: 110,
          payment_state: "paid",
          shipment_state: "shipped"
        )

        expect(order.payments.count).to eq 1
        expect(order.payments[0]).to have_attributes(
          amount: 110,
          state: 'completed'
        )

        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          state: 'shipped'
        )

        expect(order.cartons.count).to eq 1
      end
    end
  end
end

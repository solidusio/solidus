require 'spec_helper'
require 'spree/testing_support/factories/order_factory'

RSpec.describe 'order factory' do
  let(:factory_class) { Spree::Order }

  describe 'plain order' do
    let(:factory) { :order }

    it_behaves_like 'a working factory'

    it "has the expected attributes" do
      order = create(factory)
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

  describe 'order with totals' do
    let(:factory) { :order_with_totals }

    it_behaves_like 'a working factory'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        # This factory is terrbily named
        expect(order.total).to eq 0
        expect(order.line_items.count).to eq 1
      end
    end
  end

  describe 'order with line items' do
    let(:factory) { :order_with_line_items }

    it_behaves_like 'a working factory'

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order.line_items.count).to eq 1
        expect(order.line_items[0]).to have_attributes(
          quantity: 1,
          price: 10
        )

        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          amount: 100
        )

        expect(order.shipments[0].inventory_units.count).to eq(1)
        expect(order.shipments[0].inventory_units[0]).to have_attributes(
          order: order,
          shipment: order.shipments[0],
          line_item: order.line_items[0],
          variant: order.line_items[0].variant,
          state: 'on_hand'
        )

        expect(order).to have_attributes(
          item_total: 10,
          ship_total: 100,
          total: 110,
          state: 'cart' # this isn't realistic
        )
      end
    end
  end

  describe 'order ready to complete' do
    let(:factory) { :order_ready_to_complete }

    it_behaves_like 'a working factory'

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
      end
    end
  end

  describe 'completed order with pending payment' do
    let(:factory) { :completed_order_with_pending_payment }

    it_behaves_like 'a working factory'

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

    it "has the expected attributes" do
      order = create(factory)
      aggregate_failures do
        expect(order).to be_completed
        expect(order).to have_attributes(
          total: 110,
          payment_total: 110,
          payment_state: "paid"
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

  describe 'completed order with promotion' do
    let(:factory) { :completed_order_with_promotion }

    it_behaves_like 'a working factory'

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
end

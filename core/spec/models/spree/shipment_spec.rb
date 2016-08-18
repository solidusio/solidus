require 'spec_helper'
require 'benchmark'

describe Spree::Shipment, type: :model do
  let(:order) { create(:order_ready_to_ship, line_items_count: 1) }
  let(:shipping_method) { create(:shipping_method, name: "UPS") }
  let(:stock_location) { create(:stock_location) }
  let(:shipment) do
    order.shipments.create!(
      state: 'pending',
      cost: 1,
      inventory_units: order.inventory_units,
      shipping_rates: [shipping_rate],
      stock_location: stock_location
    )
  end
  let(:shipping_rate) do
    Spree::ShippingRate.create!(
      shipping_method: shipping_method,
      selected: true
    )
  end

  let(:variant) { mock_model(Spree::Variant) }
  let(:line_item) { mock_model(Spree::LineItem, variant: variant) }

  context '#transfer_to_location' do
    it 'transfers unit to a new shipment with given location' do
      order = create(:completed_order_with_totals, line_items_count: 2)
      shipment = order.shipments.first
      variant = order.inventory_units.map(&:variant).first

      aggregate_failures("verifying new shipment attributes") do
        expect do
          shipment.transfer_to_location(variant, 1, stock_location)
        end.to change { Spree::Shipment.count }.by(1)

        new_shipment = order.shipments.last
        expect(new_shipment.number).to_not eq(shipment.number)
        expect(new_shipment.stock_location).to eq(stock_location)
        expect(new_shipment.line_items.count).to eq(1)
        expect(new_shipment.line_items.first.variant).to eq(variant)
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4063
  context "number generation" do
    before { allow(order).to receive :update! }

    it "generates a number containing a letter + 11 numbers" do
      shipment.save
      expect(shipment.number[0]).to eq("H")
      expect(/\d{11}/.match(shipment.number)).not_to be_nil
      expect(shipment.number.length).to eq(12)
    end
  end

  it 'is backordered if one if its inventory_units is backordered' do
    shipment.inventory_units = [
      build(:inventory_unit, state: 'backordered', shipment: nil),
      build(:inventory_unit, state: 'shipped', shipment: nil)
    ]
    expect(shipment).to be_backordered
  end

  context '#determine_state' do
    it 'returns canceled if order is canceled?' do
      allow(order).to receive_messages canceled?: true
      expect(shipment.determine_state(order)).to eq 'canceled'
    end

    it 'returns pending unless order.can_ship?' do
      allow(order).to receive_messages can_ship?: false
      expect(shipment.determine_state(order)).to eq 'pending'
    end

    it 'returns pending if backordered' do
      allow(shipment).to receive_messages inventory_units: [mock_model(Spree::InventoryUnit, allow_ship?: false, canceled?: false)]
      expect(shipment.determine_state(order)).to eq 'pending'
    end

    it 'returns shipped when already shipped' do
      allow(shipment).to receive_messages state: 'shipped'
      expect(shipment.determine_state(order)).to eq 'shipped'
    end

    it 'returns pending when unpaid' do
      allow(order).to receive_messages paid?: false
      expect(shipment.determine_state(order)).to eq 'pending'
    end

    it 'returns ready when paid' do
      allow(order).to receive_messages paid?: true
      expect(shipment.determine_state(order)).to eq 'ready'
    end
  end

  context "display_amount" do
    it "retuns a Spree::Money" do
      shipment.cost = 21.22
      expect(shipment.display_amount).to eq(Spree::Money.new(21.22))
    end
  end

  context "display_final_price" do
    it "retuns a Spree::Money" do
      allow(shipment).to receive(:final_price) { 21.22 }
      expect(shipment.display_final_price).to eq(Spree::Money.new(21.22))
    end
  end

  context "display_item_cost" do
    it "retuns a Spree::Money" do
      allow(shipment).to receive(:item_cost) { 21.22 }
      expect(shipment.display_item_cost).to eq(Spree::Money.new(21.22))
    end
  end

  context "#item_cost" do
    it 'should equal line items final amount with tax' do
      shipment = create(:shipment, order: create(:order_with_totals))
      create :tax_adjustment, adjustable: shipment.order.line_items.first, order: shipment.order
      shipment.order.update!
      expect(shipment.item_cost).to eql(11.0)
    end
  end

  it "#discounted_cost" do
    shipment = create(:shipment)
    shipment.cost = 10
    shipment.promo_total = -1
    expect(shipment.discounted_cost).to eq(9)
  end

  it "#tax_total with included taxes" do
    shipment = Spree::Shipment.new
    expect(shipment.tax_total).to eq(0)
    shipment.included_tax_total = 10
    expect(shipment.tax_total).to eq(10)
  end

  it "#tax_total with additional taxes" do
    shipment = Spree::Shipment.new
    expect(shipment.tax_total).to eq(0)
    shipment.additional_tax_total = 10
    expect(shipment.tax_total).to eq(10)
  end

  it "#final_price" do
    shipment = Spree::Shipment.new
    shipment.cost = 10
    shipment.adjustment_total = -2
    shipment.included_tax_total = 1
    expect(shipment.final_price).to eq(8)
  end

  context "manifest" do
    let(:order) { create(:order) }
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add variant }
    let!(:shipment) { order.create_proposed_shipments.first }

    it "returns variant expected" do
      expect(shipment.manifest.first.variant).to eq variant
    end

    context "variant was removed" do
      before { variant.destroy }

      it "still returns variant expected" do
        expect(shipment.manifest.first.variant).to eq variant
      end
    end
  end

  context 'shipping_rates' do
    let(:shipment) { create(:shipment) }
    let(:shipping_method1) { create(:shipping_method) }
    let(:shipping_method2) { create(:shipping_method) }
    let(:shipping_rates) {
      [
      Spree::ShippingRate.new(shipping_method: shipping_method1, cost: 10.00, selected: true),
      Spree::ShippingRate.new(shipping_method: shipping_method2, cost: 20.00)
    ]
    }

    it 'returns shipping_method from selected shipping_rate' do
      shipment.shipping_rates.delete_all
      shipment.shipping_rates.create shipping_method: shipping_method1, cost: 10.00, selected: true
      expect(shipment.shipping_method).to eq shipping_method1
    end

    context 'refresh_rates' do
      let(:mock_estimator) { double('estimator', shipping_rates: shipping_rates) }
      before { allow(shipment).to receive(:can_get_rates?){ true } }

      it 'should request new rates, and maintain shipping_method selection' do
        expect(Spree::Stock::Estimator).to receive(:new).with(no_args).and_return(mock_estimator)
        allow(shipment).to receive_messages(shipping_method: shipping_method2)

        expect(shipment.refresh_rates).to eq(shipping_rates)
        expect(shipment.reload.selected_shipping_rate.shipping_method_id).to eq(shipping_method2.id)
      end

      it 'should handle no shipping_method selection' do
        expect(Spree::Stock::Estimator).to receive(:new).with(no_args).and_return(mock_estimator)
        allow(shipment).to receive_messages(shipping_method: nil)
        expect(shipment.refresh_rates).to eq(shipping_rates)
        expect(shipment.reload.selected_shipping_rate).not_to be_nil
      end

      it 'should not refresh if shipment is shipped' do
        expect(Spree::Stock::Estimator).not_to receive(:new)
        shipment.shipping_rates.delete_all
        allow(shipment).to receive_messages(shipped?: true)
        expect(shipment.refresh_rates).to eq([])
      end

      it "can't get rates without a shipping address" do
        shipment.order.update_attributes!(ship_address: nil)
        expect(shipment.refresh_rates).to eq([])
      end

      it 'uses the pluggable estimator class' do
        expect(Spree::Config.stock).to receive(:estimator_class).and_call_original
        shipment.refresh_rates
      end

      context 'to_package' do
        let(:inventory_units) do
          [build(:inventory_unit, line_item: line_item, variant: variant, state: 'on_hand'),
           build(:inventory_unit, line_item: line_item, variant: variant, state: 'backordered')]
        end

        before do
          allow(shipment).to receive(:inventory_units) { inventory_units }
          allow(inventory_units).to receive_message_chain(:includes, :joins).and_return inventory_units
        end

        it 'should use symbols for states when adding contents to package' do
          package = shipment.to_package
          expect(package.on_hand.count).to eq 1
          expect(package.backordered.count).to eq 1
        end

        it 'should set the shipment to itself' do
          expect(shipment.to_package.shipment).to eq(shipment)
        end
      end
    end
  end

  context "#update!" do
    shared_examples_for "immutable once shipped" do
      before { shipment.update_columns(state: 'shipped') }

      it "should remain in shipped state once shipped" do
        expect {
          shipment.update!(order)
        }.not_to change { shipment.state }
      end
    end

    shared_examples_for "pending if backordered" do
      it "should have a state of pending if backordered" do
        # Set as ready so we can test for change
        shipment.update_attributes!(state: 'ready')

        allow(shipment).to receive_messages(inventory_units: [mock_model(Spree::InventoryUnit, allow_ship?: false, canceled?: false)])
        expect(shipment).to receive(:update_columns).with(state: 'pending', updated_at: kind_of(Time))
        shipment.update!(order)
      end
    end

    context "when order cannot ship" do
      before { allow(order).to receive_messages can_ship?: false }
      it "should result in a 'pending' state" do
        # Set as ready so we can test for change
        shipment.update_attributes!(state: 'ready')
        expect(shipment).to receive(:update_columns).with(state: 'pending', updated_at: kind_of(Time))
        shipment.update!(order)
      end
    end

    context "when order is paid" do
      before { allow(order).to receive_messages paid?: true }
      it "should result in a 'ready' state" do
        expect(shipment).to receive(:update_columns).with(state: 'ready', updated_at: kind_of(Time))
        shipment.update!(order)
      end
      it_should_behave_like 'immutable once shipped'
      it_should_behave_like 'pending if backordered'
    end

    context "when payment is not required" do
      before do
        Spree::Config[:require_payment_to_ship] = false
      end

      it "should result in a 'ready' state" do
        expect(shipment).to receive(:update_columns).with(state: 'ready', updated_at: kind_of(Time))
        shipment.update!(order)
      end
      it_should_behave_like 'immutable once shipped'
      it_should_behave_like 'pending if backordered'
    end

    context "when order has balance due" do
      before { allow(order).to receive_messages paid?: false }
      it "should result in a 'pending' state" do
        shipment.state = 'ready'
        expect(shipment).to receive(:update_columns).with(state: 'pending', updated_at: kind_of(Time))
        shipment.update!(order)
      end
      it_should_behave_like 'immutable once shipped'
      it_should_behave_like 'pending if backordered'
    end

    context "when order has a credit owed" do
      before { allow(order).to receive_messages payment_state: 'credit_owed', paid?: true }
      it "should result in a 'ready' state" do
        shipment.state = 'pending'
        expect(shipment).to receive(:update_columns).with(state: 'ready', updated_at: kind_of(Time))
        shipment.update!(order)
      end
      it_should_behave_like 'immutable once shipped'
      it_should_behave_like 'pending if backordered'
    end

    context "when shipment state changes to shipped" do
      it "should call after_ship" do
        shipment.state = 'pending'
        expect(shipment).to receive :after_ship
        allow(shipment).to receive_messages determine_state: 'shipped'
        expect(shipment).to receive(:update_columns).with(state: 'shipped', updated_at: kind_of(Time))
        shipment.update!(order)
      end

      # Regression test for https://github.com/spree/spree/issues/4347
      context "with adjustments" do
        before do
          shipment.adjustments << Spree::Adjustment.create(order: order, label: "Label", amount: 5)
        end

        it "transitions to shipped" do
          shipment.update_column(:state, "ready")
          shipment.ship!
        end
      end
    end
  end

  context "when order is completed" do
    before do
      allow(order).to receive_messages completed?: true
      allow(order).to receive_messages canceled?: false
    end

    context "with inventory tracking" do
      before { Spree::Config.set track_inventory_levels: true }

      it "should validate with inventory" do
        shipment.inventory_units = [create(:inventory_unit)]
        expect(shipment.valid?).to be true
      end
    end

    context "without inventory tracking" do
      before { Spree::Config.set track_inventory_levels: false }

      it "should validate with no inventory" do
        expect(shipment.valid?).to be true
      end
    end
  end

  context "#cancel" do
    it 'cancels the shipment' do
      allow(shipment.order).to receive(:update!)

      shipment.state = 'pending'
      expect(shipment).to receive(:after_cancel)
      shipment.cancel!
      expect(shipment.state).to eq 'canceled'
    end

    it 'restocks the items' do
      variant = shipment.inventory_units.first.variant
      shipment.stock_location = mock_model(Spree::StockLocation)
      expect(shipment.stock_location).to receive(:restock).with(variant, 1, shipment)
      shipment.after_cancel
    end

    context "with backordered inventory units" do
      let(:order) { create(:order) }
      let(:variant) { create(:variant) }
      let(:other_order) { create(:order) }

      before do
        order.contents.add variant
        order.create_proposed_shipments

        other_order.contents.add variant
        other_order.create_proposed_shipments
      end

      it "doesn't fill backorders when restocking inventory units" do
        shipment = order.shipments.first
        expect(shipment.inventory_units.count).to eq 1
        expect(shipment.inventory_units.first).to be_backordered

        other_shipment = other_order.shipments.first
        expect(other_shipment.inventory_units.count).to eq 1
        expect(other_shipment.inventory_units.first).to be_backordered

        expect {
          shipment.cancel!
        }.not_to change { other_shipment.inventory_units.first.state }
      end
    end
  end

  context "#resume" do
    let(:inventory_unit) { create(:inventory_unit) }

    before { shipment.state = 'canceled' }

    context "when order cannot ship" do
      before { allow(order).to receive_messages(can_ship?: false) }
      it "should result in a 'pending' state" do
        shipment.resume!
        expect(shipment.state).to eq 'pending'
      end
    end

    context "when order is not paid" do
      before { allow(order).to receive_messages(paid?: false) }
      it "should result in a 'ready' state" do
        shipment.resume!
        expect(shipment.state).to eq 'pending'
      end
    end

    context "when any inventory is backordered" do
      before { allow_any_instance_of(Spree::InventoryUnit).to receive(:allow_ship?).and_return(false) }
      it "should result in a 'ready' state" do
        shipment.resume!
        expect(shipment.state).to eq 'pending'
      end
    end

    context "when the order is paid, shippable, and not backordered" do
      before do
        allow(order).to receive_messages(can_ship?: true)
        allow(order).to receive_messages(paid?: true)
        allow_any_instance_of(Spree::InventoryUnit).to receive(:allow_ship?).and_return(true)
      end

      it "should result in a 'ready' state" do
        shipment.resume!
        expect(shipment.state).to eq 'ready'
      end
    end

    it 'unstocks them items' do
      variant = shipment.inventory_units.first.variant
      shipment.stock_location = mock_model(Spree::StockLocation)
      expect(shipment.stock_location).to receive(:unstock).with(variant, 1, shipment)
      shipment.after_resume
    end
  end

  context "#ship" do
    context "when the shipment is canceled" do
      let(:address){ create(:address) }
      let(:order){ create(:order_with_line_items, ship_address: address) }
      let(:shipment_with_inventory_units) { create(:shipment, order: order, state: 'canceled') }
      let(:subject) { shipment_with_inventory_units.ship! }
      before do
        allow(order).to receive(:update!)
        allow(shipment_with_inventory_units).to receive_messages(require_inventory: false, update_order: true)
      end

      it 'unstocks them items' do
        expect(shipment_with_inventory_units.stock_location).to receive(:unstock).with(an_instance_of(Spree::Variant), 1, shipment_with_inventory_units)
        subject
      end
    end

    ['ready', 'canceled'].each do |state|
      context "from #{state}" do
        before do
          allow(order).to receive(:update!)
          allow(shipment).to receive_messages(require_inventory: false, update_order: true, state: state)
        end

        it "should call fulfill_order_with_stock_location" do
          expect(Spree::OrderStockLocation).to(
            receive(:fulfill_for_order_with_stock_location).
            with(order, stock_location)
          )
          shipment.ship!
        end

        it "finalizes adjustments" do
          shipment.adjustments.each do |adjustment|
            expect(adjustment).to receive(:finalize!)
          end
          shipment.ship!
        end
      end
    end
  end

  context "#ready" do
    # Regression test for https://github.com/spree/spree/issues/2040
    it "cannot ready a shipment for an order if the order is unpaid" do
      expect(order).to receive_messages(paid?: false)
      expect(shipment).not_to be_can_ready
    end
  end

  context "updates cost when selected shipping rate is present" do
    let(:shipment) { create(:shipment) }

    before { allow(shipment).to receive_message_chain :selected_shipping_rate, cost: 5 }

    it "updates shipment totals" do
      shipment.update_amounts
      expect(shipment.reload.cost).to eq(5)
    end

    it "factors in additional adjustments to adjustment total" do
      shipment.adjustments.create!(
        order:    order,
        label:    "Additional",
        amount:   5,
        included: false,
        finalized: true
      )
      shipment.update_amounts
      expect(shipment.reload.adjustment_total).to eq(5)
    end

    it "does not factor in included adjustments to adjustment total" do
      shipment.adjustments.create!(
        order:    order,
        label:    "Included",
        amount:   5,
        included: true,
        finalized: true
      )
      shipment.update_amounts
      expect(shipment.reload.adjustment_total).to eq(0)
    end
  end

  context "changes shipping rate via general update" do
    let(:store) { create :store }
    let(:order) do
      Spree::Order.create(
        payment_total: 100,
        payment_state: 'paid',
        total: 100,
        item_total: 100,
        store: store
      )
    end

    let(:shipment) { Spree::Shipment.create order_id: order.id }

    let(:shipping_rate) do
      Spree::ShippingRate.create shipment_id: shipment.id, cost: 10
    end

    before do
      shipment.update_attributes_and_order selected_shipping_rate_id: shipping_rate.id
    end

    it "updates everything around order shipment total and state" do
      expect(shipment.cost.to_f).to eq 10
      expect(shipment.state).to eq 'pending'
      expect(shipment.order.total.to_f).to eq 110
      expect(shipment.order.payment_state).to eq 'balance_due'
    end
  end

  context "currency" do
    it "returns the order currency" do
      expect(shipment.currency).to eq(order.currency)
    end
  end

  context "nil costs" do
    it "sets cost to 0" do
      shipment = Spree::Shipment.new
      shipment.valid?
      expect(shipment.cost).to eq 0
    end
  end

  context "#tracking_url" do
    subject { shipment.tracking_url }

    context "when tracking has not yet been set" do
      it { is_expected.to be nil }
    end

    context "when tracking has been set, but a shipping method is not present" do
      before do
        shipment.tracking = "12345"
        shipment.shipping_rates.clear
      end

      it { is_expected.to be nil }
    end

    context "when tracking has been set and a shipping method exists" do
      before do
        shipment.tracking = "12345"
        shipment.shipping_method.update(tracking_url: "https://example.com/:tracking")
      end

      it "builds the tracking url with the shipping method" do
        expect(subject).to eql("https://example.com/12345")
      end
    end
  end

  context "set up new inventory units" do
    # let(:line_item) { double(
    let(:variant) { double("Variant", id: 9) }

    let(:inventory_units) { double }

    let(:params) do
      { variant_id: variant.id, state: 'on_hand', order_id: order.id, line_item_id: line_item.id }
    end

    before { allow(shipment).to receive_messages inventory_units: inventory_units }

    it "associates variant and order" do
      expect(inventory_units).to receive(:create).with(params)
      shipment.set_up_inventory('on_hand', variant, order, line_item)
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3349
  context "#destroy" do
    it "destroys linked shipping_rates" do
      reflection = Spree::Shipment.reflect_on_association(:shipping_rates)
      expect(reflection.options[:dependent]).to be(:delete_all)
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4072 (kinda)
  # The need for this was discovered in the research for https://github.com/spree/spree/issues/4702
  context "state changes" do
    before do
      # Must be stubbed so transition can succeed
      allow(order).to receive_messages paid?: true
    end

    it "are logged to the database" do
      expect(shipment.state_changes).to be_empty
      expect(shipment.ready!).to be true
      expect(shipment.state_changes.count).to eq(1)
      state_change = shipment.state_changes.first
      expect(state_change.previous_state).to eq('pending')
      expect(state_change.next_state).to eq('ready')
    end
  end

  context "don't require shipment" do
    let(:stock_location) { create(:stock_location, fulfillable: false) }
    let(:unshippable_shipment) do
      create(
        :shipment,
        stock_location: stock_location,
        inventory_units: [build(:inventory_unit)]
      )
    end

    before { allow(order).to receive_messages paid?: true }

    it 'proceeds automatically to shipped state' do
      unshippable_shipment.ready!
      expect(unshippable_shipment.state).to eq('shipped')
    end

    it 'does not send a confirmation email' do
      expect {
        unshippable_shipment.ready!
        unshippable_shipment.inventory_units.reload.each do |unit|
          expect(unit.state).to eq('shipped')
        end
      }.not_to change{ ActionMailer::Base.deliveries.count }
    end
  end

  context "destroy prevention" do
    it "can be destroyed when pending" do
      shipment = create(:shipment, state: "pending")
      expect(shipment.destroy).to be_truthy
      expect { shipment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cannot be destroyed when ready" do
      shipment = create(:shipment, state: "ready")
      expect(shipment.destroy).to eq false
      expect(shipment.errors.full_messages.join).to match /Cannot destroy/
      expect { shipment.reload }.not_to raise_error
    end

    it "cannot be destroyed when shipped" do
      shipment = create(:shipment, state: "shipped")
      expect(shipment.destroy).to eq false
      expect(shipment.errors.full_messages.join).to match /Cannot destroy/
      expect { shipment.reload }.not_to raise_error
    end

    it "cannot be destroyed when canceled" do
      shipment = create(:shipment, state: "canceled")
      expect(shipment.destroy).to eq false
      expect(shipment.errors.full_messages.join).to match /Cannot destroy/
      expect { shipment.reload }.not_to raise_error
    end
  end

  describe "#finalize!" do
    let(:inventory_unit) { shipment.inventory_units.first }
    let(:stock_item) { inventory_unit.variant.stock_items.find_by(stock_location: stock_location) }

    before do
      stock_item.set_count_on_hand(10)
      stock_item.update_attributes!(backorderable: false)
    end

    subject { shipment.finalize! }

    it "updates the associated inventory units" do
      inventory_unit.update_columns(updated_at: 1.hour.ago)
      expect { subject }.to change { inventory_unit.reload.updated_at }
    end

    it "unstocks the variant" do
      expect { subject }.to change { stock_item.reload.count_on_hand }.from(10).to(9)
    end

    context "inventory unit already finalized" do
      before do
        inventory_unit.update_attributes!(pending: false)
      end

      it "doesn't update the associated inventory units" do
        expect { subject }.to_not change { inventory_unit.reload.updated_at }
      end

      it "doesn't unstock the variant" do
        expect { subject }.to_not change { stock_item.reload.count_on_hand }
      end
    end
  end

  describe ".by_store" do
    it "returns shipments by store" do
      olivanders_store = create(:store, name: 'Olivanders')
      wizard_shipment = create(:shipment, order: create(:order, store: olivanders_store))
      create(:shipment, order: build(:order, store: create(:store, name: 'Target')))

      shipments = Spree::Shipment.by_store(olivanders_store)

      expect(Spree::Shipment.count).to eq(2)
      expect(shipments.count).to eq(1)
      expect(shipments.first).to eq(wizard_shipment)
    end
  end

  describe '#selected_shipping_rate_id=' do
    let!(:air_shipping_method) { create(:shipping_method, name: "Air") }
    let(:new_rate) { shipment.add_shipping_method(air_shipping_method) }

    context 'when the id exists' do
      it 'sets the new shipping rate as selected' do
        expect {
          shipment.selected_shipping_rate_id = new_rate.id
        }.to change { new_rate.selected }.from(false).to(true)
      end

      it 'sets the old shipping rate as not selected' do
        expect {
          shipment.selected_shipping_rate_id = new_rate.id
        }.to change { shipping_rate.selected }.from(true).to(false)
      end
    end

    context 'when the id does not exist' do
      it 'raises a RecordNotFound error' do
        expect {
          shipment.selected_shipping_rate_id = -1
        }.to raise_error(ArgumentError)
      end
    end
  end
end

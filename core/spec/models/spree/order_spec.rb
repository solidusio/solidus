require 'spec_helper'

class FakeCalculator < Spree::Calculator
  def compute(_computable)
    5
  end
end

describe Spree::Order, type: :model do
  let(:store) { build_stubbed(:store) }
  let(:user) { stub_model(Spree::LegacyUser, email: "spree@example.com") }
  let(:order) { stub_model(Spree::Order, user: user, store: store) }

  before do
    allow(Spree::LegacyUser).to receive_messages(current: mock_model(Spree::LegacyUser, id: 123))
  end

  context '#store' do
    it { is_expected.to respond_to(:store) }

    context 'when there is no store assigned' do
      subject { Spree::Order.new }

      context 'when there is no default store' do
        it "will not be valid" do
          expect(subject).not_to be_valid
        end
      end

      context "when there is a default store" do
        let!(:store) { create(:store) }

        it { is_expected.to be_valid }
      end
    end

    context 'when a store is assigned' do
      subject { Spree::Order.new(store: create(:store)) }
      it { is_expected.to be_valid }
    end
  end

  describe "#cancel!" do
    context "with captured store credit" do
      let!(:store_credit_payment_method) { create(:store_credit_payment_method) }
      let(:order_total) { 500.00 }
      let(:store_credit) { create(:store_credit, amount: order_total) }
      let(:order) { create(:order_with_line_items, user: store_credit.user, line_items_price: order_total) }

      before do
        order.add_store_credit_payments
        order.finalize!
        order.capture_payments!
      end

      subject { order.cancel! }

      it "cancels the order" do
        expect{ subject }.to change{ order.can_cancel? }.from(true).to(false)
        expect(order).to be_canceled
      end
    end
  end

  context "#canceled_by" do
    let(:admin_user) { create :admin_user }
    let(:order) { create :order }

    before do
      allow(order).to receive(:cancel!)
    end

    subject { order.canceled_by(admin_user) }

    it 'should cancel the order' do
      expect(order).to receive(:cancel!)
      subject
    end

    it 'should save canceler_id' do
      subject
      expect(order.reload.canceler_id).to eq(admin_user.id)
    end

    it 'should save canceled_at' do
      subject
      expect(order.reload.canceled_at).to_not be_nil
    end

    it 'should have canceler' do
      subject
      expect(order.reload.canceler).to eq(admin_user)
    end
  end

  context "#create" do
    let!(:store) { create :store }
    let(:order) { Spree::Order.create }

    it "should assign an order number" do
      expect(order.number).not_to be_nil
    end

    it 'should create a randomized 22 character token' do
      expect(order.guest_token.size).to eq(22)
    end
  end

  context "creates shipments cost" do
    let(:shipment) { double }

    before { allow(order).to receive_messages shipments: [shipment] }

    it "update and persist totals" do
      expect(shipment).to receive :update_amounts
      expect(order.updater).to receive :update_shipment_total
      expect(order.updater).to receive :persist_totals

      order.set_shipments_cost
    end
  end

  context "insufficient_stock_lines" do
    let(:line_item) { mock_model Spree::LineItem, insufficient_stock?: true }

    before { allow(order).to receive_messages(line_items: [line_item]) }

    it "should return line_item that has insufficient stock on hand" do
      expect(order.insufficient_stock_lines.size).to eq(1)
      expect(order.insufficient_stock_lines.include?(line_item)).to be true
    end
  end

  describe '#ensure_line_item_variants_are_not_deleted' do
    subject { order.ensure_line_item_variants_are_not_deleted }

    let(:order) { create :order_with_line_items }

    context 'when variant is destroyed' do
      before do
        allow(order).to receive(:restart_checkout_flow)
        order.line_items.first.variant.destroy
      end

      it 'should restart checkout flow' do
        expect(order).to receive(:restart_checkout_flow).once
        subject
      end

      it 'should have error message' do
        subject
        expect(order.errors[:base]).to include(Spree.t(:deleted_variants_present))
      end

      it 'should be false' do
        expect(subject).to be_falsey
      end
    end

    context 'when no variants are destroyed' do
      it 'should not restart checkout' do
        expect(order).to receive(:restart_checkout_flow).never
        subject
      end

      it 'should be true' do
        expect(subject).to be_truthy
      end
    end
  end

  context "empty!" do
    let!(:order) { create(:order) }

    before do
      create(:line_item, order: order)
      create(:shipment, order: order)
      create(:adjustment, adjustable: order, order: order)
      order.update!

      # Make sure we are asserting changes
      expect(order.line_items).not_to be_empty
      expect(order.shipments).not_to be_empty
      expect(order.adjustments).not_to be_empty
      expect(order.item_total).not_to eq 0
      expect(order.item_count).not_to eq 0
      expect(order.shipment_total).not_to eq 0
      expect(order.adjustment_total).not_to eq 0
    end

    it "clears out line items, adjustments and update totals" do
      order.empty!
      expect(order.line_items).to be_empty
      expect(order.shipments).to be_empty
      expect(order.adjustments).to be_empty
      expect(order.item_total).to eq 0
      expect(order.item_count).to eq 0
      expect(order.shipment_total).to eq 0
      expect(order.adjustment_total).to eq 0
    end
  end

  context "#display_outstanding_balance" do
    it "returns the value as a spree money" do
      allow(order).to receive(:outstanding_balance) { 10.55 }
      expect(order.display_outstanding_balance).to eq(Spree::Money.new(10.55))
    end
  end

  context "#display_item_total" do
    it "returns the value as a spree money" do
      allow(order).to receive(:item_total) { 10.55 }
      expect(order.display_item_total).to eq(Spree::Money.new(10.55))
    end
  end

  context "#display_adjustment_total" do
    it "returns the value as a spree money" do
      order.adjustment_total = 10.55
      expect(order.display_adjustment_total).to eq(Spree::Money.new(10.55))
    end
  end

  context "#display_total" do
    it "returns the value as a spree money" do
      order.total = 10.55
      expect(order.display_total).to eq(Spree::Money.new(10.55))
    end
  end

  context "#currency" do
    context "when object currency is ABC" do
      before { order.currency = "ABC" }

      it "returns the currency from the object" do
        expect(order.currency).to eq("ABC")
      end
    end

    context "when object currency is nil" do
      before { order.currency = nil }

      it "returns the globally configured currency" do
        expect(order.currency).to eq("USD")
      end
    end
  end

  describe '#merge!' do
    let(:order1) { create(:order_with_line_items) }
    let(:order2) { create(:order_with_line_items) }

    it 'merges the orders' do
      order1.merge!(order2)
      expect(order1.line_items.count).to eq(2)
      expect(order2.destroyed?).to be_truthy
    end

    describe 'order_merger_class customization' do
      before do
        class TestOrderMerger
          def initialize(order)
            @order = order
          end

          def merge!(other_order, user = nil)
            [@order, other_order, user]
          end
        end
        Spree::Config.order_merger_class = TestOrderMerger
      end

      let(:user) { build(:user) }

      it 'uses the configured order merger' do
        expect(order1.merge!(order2, user)).to eq([order1, order2, user])
      end
    end
  end

  context "add_update_hook" do
    before do
      Spree::Order.class_eval do
        register_update_hook :add_awesome_sauce
      end
    end

    after do
      Spree::Order.update_hooks = Set.new
    end

    it "calls hook during update" do
      order = create(:order)
      expect(order).to receive(:add_awesome_sauce)
      order.update!
    end

    it "calls hook during finalize" do
      order = create(:order)
      expect(order).to receive(:add_awesome_sauce)
      order.finalize!
    end
  end

  context "ensure shipments will be updated" do
    subject(:order) { create :order }
    before do
      Spree::Shipment.create!(order: order)
    end

    ['payment', 'confirm'].each do |order_state|
      context "when ther order is in the #{order_state} state" do
        before do
          order.state = order_state
          order.shipments.create!
        end

        it "destroys current shipments" do
          order.ensure_updated_shipments
          expect(order.shipments).to be_empty
        end

        it "puts order back in address state" do
          order.ensure_updated_shipments
          expect(order.state).to eql "cart"
        end

        it "resets shipment_total" do
          order.update_column(:shipment_total, 5)
          order.ensure_updated_shipments
          expect(order.shipment_total).to eq(0)
        end

        it "does nothing if any shipments are ready" do
          shipment = create(:shipment, order: subject, state: "ready")
          expect { subject.ensure_updated_shipments }.not_to change { subject.reload.shipments }
          expect { shipment.reload }.not_to raise_error
        end

        it "does nothing if any shipments are shipped" do
          shipment = create(:shipment, order: subject, state: "shipped")
          expect { subject.ensure_updated_shipments }.not_to change { subject.reload.shipments }
          expect { shipment.reload }.not_to raise_error
        end
      end
    end

    context 'when the order is in address state' do
      before do
        order.state = 'address'
        order.shipments.create!
      end

      it "destroys current shipments" do
        order.ensure_updated_shipments
        expect(order.shipments).to be_empty
      end

      it "resets shipment_total" do
        order.update_column(:shipment_total, 5)
        order.ensure_updated_shipments
        expect(order.shipment_total).to eq(0)
      end

      it "puts the order in the cart state" do
        order.ensure_updated_shipments
        expect(order.state).to eq "cart"
      end
    end

    context 'when the order is completed' do
      before do
        order.state = 'complete'
        order.completed_at = Time.current
        order.update_column(:shipment_total, 5)
        order.shipments.create!
      end

      it "does not destroy the current shipments" do
        expect {
          order.ensure_updated_shipments
        }.not_to change { order.shipments }
      end

      it "does not reset the shipment total" do
        expect {
          order.ensure_updated_shipments
        }.not_to change { order.shipment_total }
      end

      it "does not put the order back in the address state" do
        expect {
          order.ensure_updated_shipments
        }.not_to change { order.state }
      end
    end

    context "except when order is completed, that's OrderInventory job" do
      it "doesn't touch anything" do
        allow(order).to receive_messages completed?: true
        order.update_column(:shipment_total, 5)
        order.shipments.create!

        expect {
          order.ensure_updated_shipments
        }.not_to change { order.shipment_total }

        expect {
          order.ensure_updated_shipments
        }.not_to change { order.shipments }

        expect {
          order.ensure_updated_shipments
        }.not_to change { order.state }
      end
    end
  end

  describe "#tax_address" do
    let(:order) { build(:order, ship_address: ship_address, bill_address: bill_address, store: store) }
    let(:store) { build(:store) }

    before { Spree::Config[:tax_using_ship_address] = tax_using_ship_address }
    subject { order.tax_address }

    context "when the order has no addresses" do
      let(:ship_address) { nil }
      let(:bill_address) { nil }

      context "when tax_using_ship_address is true" do
        let(:tax_using_ship_address) { true }

        it 'returns the stores default cart tax location' do
          expect(subject).to eq(store.default_cart_tax_location)
        end
      end

      context "when tax_using_ship_address is not true" do
        let(:tax_using_ship_address) { false }

        it 'returns the stores default cart tax location' do
          expect(subject).to eq(store.default_cart_tax_location)
        end
      end
    end

    context "when the order has addresses" do
      let(:ship_address) { build(:address) }
      let(:bill_address) { build(:address) }

      context "when tax_using_ship_address is true" do
        let(:tax_using_ship_address) { true }

        it 'returns ship_address' do
          expect(subject).to eq(order.ship_address)
        end
      end

      context "when tax_using_ship_address is not true" do
        let(:tax_using_ship_address) { false }

        it "returns bill_address" do
          expect(subject).to eq(order.bill_address)
        end
      end
    end
  end

  describe "#restart_checkout_flow" do
    context "when in cart state" do
      let(:order) { create(:order_with_totals, state: "cart") }

      it "remains in cart state" do
        expect { order.restart_checkout_flow }.not_to change { order.state }
      end
    end
    it "updates the state column to the first checkout_steps value" do
      order = create(:order_with_totals, state: "delivery")
      expect(order.checkout_steps).to eql ["address", "delivery", "confirm", "complete"]
      expect{ order.restart_checkout_flow }.to change{ order.state }.from("delivery").to("address")
    end

    context "without line items" do
      it "updates the state column to cart" do
        order = create(:order, state: "delivery")
        expect{ order.restart_checkout_flow }.to change{ order.state }.from("delivery").to("cart")
      end
    end
  end

  # Regression tests for https://github.com/spree/spree/issues/4072
  context "#state_changed" do
    let(:order) { FactoryGirl.create(:order) }

    it "logs state changes" do
      order.update_column(:payment_state, 'balance_due')
      order.payment_state = 'paid'
      expect(order.state_changes).to be_empty
      order.state_changed('payment')
      state_change = order.state_changes.find_by(name: 'payment')
      expect(state_change.previous_state).to eq('balance_due')
      expect(state_change.next_state).to eq('paid')
    end

    it "does not do anything if state does not change" do
      order.update_column(:payment_state, 'balance_due')
      expect(order.state_changes).to be_empty
      order.state_changed('payment')
      expect(order.state_changes).to be_empty
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4199
  context "#available_payment_methods" do
    it "includes frontend payment methods" do
      payment_method = Spree::PaymentMethod.create!({
        name: "Fake",
        active: true,
        display_on: "front_end"
      })
      expect(order.available_payment_methods).to include(payment_method)
    end

    it "includes 'both' payment methods" do
      payment_method = Spree::PaymentMethod.create!({
        name: "Fake",
        active: true,
        display_on: "both"
      })
      expect(order.available_payment_methods).to include(payment_method)
    end

    it "does not include a payment method twice if display_on is blank" do
      payment_method = Spree::PaymentMethod.create!({
        name: "Fake",
        active: true,
        display_on: "both"
      })
      expect(order.available_payment_methods.count).to eq(1)
      expect(order.available_payment_methods).to include(payment_method)
    end

    context "with more than one payment method" do
      subject { order.available_payment_methods }

      let!(:first_method) { FactoryGirl.create(:payment_method, display_on: :both) }
      let!(:second_method) { FactoryGirl.create(:payment_method, display_on: :both) }

      before do
        second_method.move_to_top
      end

      it "respects the order of methods based on position" do
        expect(subject).to eql([second_method, first_method])
      end
    end

    context 'when the order has a store' do
      let(:order) { create(:order) }

      let!(:store_with_payment_methods) do
        create(:store,
          payment_methods: [payment_method_with_store]
        )
      end
      let!(:payment_method_with_store) { create(:payment_method) }
      let!(:store_without_payment_methods) { create(:store) }
      let!(:payment_method_without_store) { create(:payment_method) }

      context 'when the store has payment methods' do
        before { order.update_attributes!(store: store_with_payment_methods) }

        it 'returns only the matching payment methods for that store' do
          expect(order.available_payment_methods).to match_array(
            [payment_method_with_store]
          )
        end
      end

      context 'when the store does not have payment methods' do
        before { order.update_attributes!(store: store_without_payment_methods) }

        it 'returns all matching payment methods regardless of store' do
          expect(order.available_payment_methods).to match_array(
            [payment_method_with_store, payment_method_without_store]
          )
        end
      end
    end
  end

  context "#apply_free_shipping_promotions" do
    it "calls out to the FreeShipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::FreeShipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.updater).to receive(:update).and_call_original

      order.apply_free_shipping_promotions
    end
  end

  context "#products" do
    before :each do
      @variant1 = mock_model(Spree::Variant, product: "product1")
      @variant2 = mock_model(Spree::Variant, product: "product2")
      @line_items = [mock_model(Spree::LineItem, product: "product1", variant: @variant1, variant_id: @variant1.id, quantity: 1),
                     mock_model(Spree::LineItem, product: "product2", variant: @variant2, variant_id: @variant2.id, quantity: 2)]
      allow(order).to receive_messages(line_items: @line_items)
    end

    it "contains?" do
      expect(order.contains?(@variant1)).to be true
    end

    it "gets the quantity of a given variant" do
      expect(order.quantity_of(@variant1)).to eq(1)

      @variant3 = mock_model(Spree::Variant, product: "product3")
      expect(order.quantity_of(@variant3)).to eq(0)
    end

    it "can find a line item matching a given variant" do
      expect(order.find_line_item_by_variant(@variant1)).not_to be_nil
      expect(order.find_line_item_by_variant(mock_model(Spree::Variant))).to be_nil
    end

    context "match line item with options" do
      before do
        Spree::Order.register_line_item_comparison_hook(:foos_match)
      end

      after do
        # reset to avoid test pollution
        Spree::Order.line_item_comparison_hooks = Set.new
      end

      it "matches line item when options match" do
        allow(order).to receive(:foos_match).and_return(true)
        expect(order.line_item_options_match(@line_items.first, { foos: { bar: :zoo } })).to be true
      end

      it "does not match line item without options" do
        allow(order).to receive(:foos_match).and_return(false)
        expect(order.line_item_options_match(@line_items.first, {})).to be false
      end
    end
  end

  context "#generate_order_number" do
    context "when no configure" do
      let(:default_length) { Spree::Order::ORDER_NUMBER_LENGTH + Spree::Order::ORDER_NUMBER_PREFIX.length }
      subject(:order_number) { order.generate_order_number }

      describe '#class' do
        subject { super().class }
        it { is_expected.to eq String }
      end

      describe '#length' do
        subject { super().length }
        it { is_expected.to eq default_length }
      end
      it { is_expected.to match /^#{Spree::Order::ORDER_NUMBER_PREFIX}/ }
    end

    context "when length option is 5" do
      let(:option_length) { 5 + Spree::Order::ORDER_NUMBER_PREFIX.length }
      it "should be option length for order number" do
        expect(order.generate_order_number(length: 5).length).to eq option_length
      end
    end

    context "when letters option is true" do
      it "generates order number include letter" do
        expect(order.generate_order_number(length: 100, letters: true)).to match /[A-Z]/
      end
    end

    context "when prefix option is 'P'" do
      it "generates order number and it prefix is 'P'" do
        expect(order.generate_order_number(prefix: 'P')).to match /^P/
      end
    end
  end

  context "#associate_user!" do
    let!(:user) { FactoryGirl.create(:user) }

    it "should associate a user with a persisted order" do
      order = FactoryGirl.create(:order_with_line_items, created_by: nil)
      order.user = nil
      order.email = nil
      order.associate_user!(user)
      expect(order.user).to eq(user)
      expect(order.email).to eq(user.email)
      expect(order.created_by).to eq(user)

      # verify that the changes we made were persisted
      order.reload
      expect(order.user).to eq(user)
      expect(order.email).to eq(user.email)
      expect(order.created_by).to eq(user)
    end

    it "should not overwrite the created_by if it already is set" do
      creator = create(:user)
      order = FactoryGirl.create(:order_with_line_items, created_by: creator)

      order.user = nil
      order.email = nil
      order.associate_user!(user)
      expect(order.user).to eq(user)
      expect(order.email).to eq(user.email)
      expect(order.created_by).to eq(creator)

      # verify that the changes we made were persisted
      order.reload
      expect(order.user).to eq(user)
      expect(order.email).to eq(user.email)
      expect(order.created_by).to eq(creator)
    end

    it "should associate a user with a non-persisted order" do
      order = Spree::Order.new

      expect do
        order.associate_user!(user)
      end.to change { [order.user, order.email] }.from([nil, nil]).to([user, user.email])
    end

    it "should not persist an invalid address" do
      address = Spree::Address.new
      order.user = nil
      order.email = nil
      order.ship_address = address
      expect do
        order.associate_user!(user)
      end.not_to change { address.persisted? }.from(false)
    end
  end

  context "#can_ship?" do
    let(:order) { Spree::Order.create }

    it "should be true for order in the 'complete' state" do
      allow(order).to receive_messages(complete?: true)
      expect(order.can_ship?).to be true
    end

    it "should be true for order in the 'resumed' state" do
      allow(order).to receive_messages(resumed?: true)
      expect(order.can_ship?).to be true
    end

    it "should be true for an order in the 'awaiting return' state" do
      allow(order).to receive_messages(awaiting_return?: true)
      expect(order.can_ship?).to be true
    end

    it "should be true for an order in the 'returned' state" do
      allow(order).to receive_messages(returned?: true)
      expect(order.can_ship?).to be true
    end

    it "should be false if the order is neither in the 'complete' nor 'resumed' state" do
      allow(order).to receive_messages(resumed?: false, complete?: false)
      expect(order.can_ship?).to be false
    end
  end

  context "#completed?" do
    it "should indicate if order is completed" do
      order.completed_at = nil
      expect(order.completed?).to be false

      order.completed_at = Time.current
      expect(order.completed?).to be true
    end
  end

  context "#allow_checkout?" do
    it "should be true if there are line_items in the order" do
      allow(order).to receive_message_chain(:line_items, count: 1)
      expect(order.checkout_allowed?).to be true
    end
    it "should be false if there are no line_items in the order" do
      allow(order).to receive_message_chain(:line_items, count: 0)
      expect(order.checkout_allowed?).to be false
    end
  end

  context "#amount" do
    before do
      @order = create(:order, user: user)
      @order.line_items = [create(:line_item, price: 1.0, quantity: 2),
                           create(:line_item, price: 1.0, quantity: 1)]
    end
    it "should return the correct lum sum of items" do
      expect(@order.amount).to eq(3.0)
    end
  end

  context "#backordered?" do
    it 'is backordered if one of the shipments is backordered' do
      allow(order).to receive_messages(shipments: [mock_model(Spree::Shipment, backordered?: false),
                                                   mock_model(Spree::Shipment, backordered?: true)])
      expect(order).to be_backordered
    end
  end

  context "#can_cancel?" do
    it "should be false for completed order in the canceled state" do
      order.state = 'canceled'
      order.shipment_state = 'ready'
      order.completed_at = Time.current
      expect(order.can_cancel?).to be false
    end

    it "should be true for completed order with no shipment" do
      order.state = 'complete'
      order.shipment_state = nil
      order.completed_at = Time.current
      expect(order.can_cancel?).to be true
    end
  end

  context "#tax_total" do
    it "adds included tax and additional tax" do
      allow(order).to receive_messages(additional_tax_total: 10, included_tax_total: 20)

      expect(order.tax_total).to eq 30
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4923
  context "locking" do
    let(:order) { Spree::Order.create } # need a persisted in order to test locking

    it 'can lock' do
      order.with_lock {}
    end
  end

  describe "#pre_tax_item_amount" do
    it "sums all of the line items' pre tax amounts" do
      subject.line_items = [
        Spree::LineItem.new(price: 10, quantity: 2, included_tax_total: 15.0),
        Spree::LineItem.new(price: 30, quantity: 1, included_tax_total: 16.0)
      ]
      # (2*10)-15 + 30-16 = 5 + 14 = 19
      expect(subject.pre_tax_item_amount).to eq 19.0
    end
  end

  context "#refund_total" do
    let(:order) { create(:order_with_line_items) }
    let!(:payment) { create(:payment_with_refund, order: order, amount: 5, refund_amount: 3) }
    let!(:payment2) { create(:payment_with_refund, order: order, amount: 5, refund_amount: 2.5) }

    it "sums the reimbursment refunds on the order" do
      expect(order.refund_total).to eq(5.5)
    end
  end

  describe '#quantity' do
    # Uses a persisted record, as the quantity is retrieved via a DB count
    let(:order) { create :order_with_line_items, line_items_count: 3 }

    it 'sums the quantity of all line items' do
      expect(order.quantity).to eq 3
    end
  end

  describe '#has_non_reimbursement_related_refunds?' do
    subject do
      order.has_non_reimbursement_related_refunds?
    end

    context 'no refunds exist' do
      it { is_expected.to eq false }
    end

    context 'a non-reimbursement related refund exists' do
      let(:order) { refund.payment.order }
      let(:refund) { create(:refund, reimbursement_id: nil, amount: 5) }

      it { is_expected.to eq true }
    end

    context 'an old-style refund exists' do
      let(:order) { create(:order_ready_to_ship) }
      let(:payment) { order.payments.first.tap { |p| allow(p).to receive_messages(profiles_supported: false) } }
      let!(:refund_payment) {
        build(:payment, amount: -1, order: order, state: 'completed', source: payment).tap do |p|
          allow(p).to receive_messages(profiles_supported?: false)
          p.save!
        end
      }

      it { is_expected.to eq true }
    end

    context 'a reimbursement related refund exists' do
      let(:order) { refund.payment.order }
      let(:refund) { create(:refund, reimbursement_id: 123, amount: 5, payment_amount: 14) }

      it { is_expected.to eq false }
    end
  end

  describe "#create_proposed_shipments" do
    subject(:order) { create(:order) }
    it "assigns the coordinator returned shipments to its shipments" do
      shipment = build(:shipment)
      allow_any_instance_of(Spree::Stock::Coordinator).to receive(:shipments).and_return([shipment])
      subject.create_proposed_shipments
      expect(subject.shipments).to eq [shipment]
    end

    it "raises an error if any shipments are ready" do
      shipment = create(:shipment, order: subject, state: "ready")
      expect {
        expect {
          subject.create_proposed_shipments
        }.to raise_error(Spree::Order::CannotRebuildShipments)
      }.not_to change { subject.reload.shipments }

      expect { shipment.reload }.not_to raise_error
    end

    it "raises an error if any shipments are shipped" do
      shipment = create(:shipment, order: subject, state: "shipped")
      expect {
        expect {
          subject.create_proposed_shipments
        }.to raise_error(Spree::Order::CannotRebuildShipments)
      }.not_to change { subject.reload.shipments }

      expect { shipment.reload }.not_to raise_error
    end

    context "unreturned exchange" do
      let!(:first_shipment) do
        create(:shipment, order: subject, state: first_shipment_state, created_at: 5.days.ago)
      end
      let!(:second_shipment) do
        create(:shipment, order: subject, state: second_shipment_state, created_at: 5.days.ago)
      end

      context "all shipments are shipped" do
        let(:first_shipment_state) { "shipped" }
        let(:second_shipment_state) { "shipped" }

        it "returns the shipments" do
          subject.create_proposed_shipments
          expect(subject.shipments).to match_array [first_shipment, second_shipment]
        end
      end
    end
  end

  describe "#all_inventory_units_returned?" do
    let(:order) { create(:order_with_line_items, line_items_count: 3) }

    subject { order.all_inventory_units_returned? }

    context "all inventory units are returned" do
      before { order.inventory_units.update_all(state: 'returned') }

      it "is true" do
        expect(subject).to eq true
      end
    end

    context "some inventory units are returned" do
      before do
        order.inventory_units.first.update_attribute(:state, 'returned')
      end

      it "is false" do
        expect(subject).to eq false
      end
    end

    context "no inventory units are returned" do
      it "is false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#unreturned_exchange?" do
    let(:order) { create(:order_with_line_items) }
    subject { order.reload.unreturned_exchange? }

    context "the order does not have a shipment" do
      before { order.shipments.destroy_all }

      it { is_expected.to be false }
    end

    context "shipment created after order" do
      it { is_expected.to be false }
    end

    context "shipment created before order" do
      before do
        order.shipments.first.update_attributes!(created_at: order.created_at - 1.day)
      end

      it { is_expected.to be true }
    end
  end

  describe '.unreturned_exchange' do
    let(:order) { create(:order_with_line_items) }
    subject { described_class.unreturned_exchange }

    it 'includes orders that have a shipment created prior to the order' do
      order.shipments.first.update_attributes!(created_at: order.created_at - 1.day)
      expect(subject).to include order
    end

    it 'excludes orders that were created prior to their shipment' do
      expect(subject).not_to include order
    end

    it 'excludes orders with no shipment' do
      order.shipments.destroy_all
      expect(subject).not_to include order
    end
  end

  describe "#fully_discounted?" do
    let(:line_item) { Spree::LineItem.new(price: 10, quantity: 1) }
    let(:shipment) { Spree::Shipment.new(cost: 10) }
    let(:payment) { Spree::Payment.new(amount: 10) }

    around do |example|
      Spree::Deprecation.silence do
        example.run
      end
    end

    before do
      allow(order).to receive(:line_items) { [line_item] }
      allow(order).to receive(:shipments) { [shipment] }
      allow(order).to receive(:payments) { [payment] }
    end

    context "the order had no inventory-related cost" do
      before do
        # discount the cost of the line items
        allow(order).to receive(:adjustment_total) { -5 }
        allow(line_item).to receive(:adjustment_total) { -5 }

        # but leave some shipment payment amount
        allow(shipment).to receive(:adjustment_total) { 0 }
      end

      it { expect(order.fully_discounted?).to eq true }
    end

    context "the order had inventory-related cost" do
      before do
        # partially discount the cost of the line item
        allow(order).to receive(:adjustment_total) { 0 }
        allow(line_item).to receive(:adjustment_total) { -5 }

        # and partially discount the cost of the shipment so the total
        # discount matches the item total for test completeness
        allow(shipment).to receive(:adjustment_total) { -5 }
      end

      it { expect(order.fully_discounted?).to eq false }
    end
  end

  context "store credit" do
    shared_examples "check total store credit from payments" do
      context "with valid payments" do
        let(:order)           { payment.order }
        let!(:payment)        { create(:store_credit_payment) }
        let!(:second_payment) { create(:store_credit_payment, order: order) }

        subject { order }

        it "returns the sum of the payment amounts" do
          expect(subject.total_applicable_store_credit).to eq(payment.amount + second_payment.amount)
        end
      end

      context "without valid payments" do
        let(:order) { create(:order) }

        subject { order }

        it "returns 0" do
          expect(subject.total_applicable_store_credit).to be_zero
        end
      end
    end

    describe "#add_store_credit_payments" do
      let(:order_total) { 500.00 }

      before { create(:store_credit_payment_method) }

      subject { order.add_store_credit_payments }

      context "there is no store credit" do
        let(:order)       { create(:order, total: order_total) }

        context "there is a credit card payment" do
          let!(:cc_payment) { create(:payment, order: order, amount: order_total) }

          before do
            # callbacks recalculate total based on line items
            # this ensures the total is what we expect
            order.update_column(:total, order_total)
            subject
            order.reload
          end

          it "charges the outstanding balance to the credit card" do
            expect(order.errors.messages).to be_empty
            expect(order.payments.count).to eq 1
            expect(order.payments.first.source).to be_a(Spree::CreditCard)
            expect(order.payments.first.amount).to eq order_total
          end
        end

      end

      context "there is enough store credit to pay for the entire order" do
        let(:store_credit) { create(:store_credit, amount: order_total) }
        let(:order) { create(:order_with_totals, user: store_credit.user, line_items_price: order_total).tap(&:update!) }

        context "there are no other payments" do
          before do
            subject
            order.reload
          end

          it "creates a store credit payment for the full amount" do
            expect(order.errors.messages).to be_empty
            expect(order.payments.count).to eq 1
            expect(order.payments.first).to be_store_credit
            expect(order.payments.first.amount).to eq order_total
          end
        end

        context "there is a credit card payment" do
          it "invalidates the credit card payment" do
            cc_payment = create(:payment, order: order)
            expect { subject }.to change { cc_payment.reload.state }.to 'invalid'
          end
        end
      end

      context "the available store credit is not enough to pay for the entire order" do
        let(:order_total) { 500 }
        let(:store_credit_total) { order_total - 100 }
        let(:store_credit)       { create(:store_credit, amount: store_credit_total) }
        let(:order) { create(:order_with_totals, user: store_credit.user, line_items_price: order_total).tap(&:update!) }

        context "there are no other payments" do
          it "adds an error to the model" do
            expect(subject).to be false
            expect(order.errors.full_messages).to include(Spree.t("store_credit.errors.unable_to_fund"))
          end
        end

        context "there is a credit card payment" do
          let!(:cc_payment) { create(:payment, order: order, state: "checkout") }

          before do
            subject
          end

          it "charges the outstanding balance to the credit card" do
            expect(order.errors.messages).to be_empty
            expect(order.payments.count).to eq 2
            expect(order.payments.first.source).to be_a(Spree::CreditCard)
            expect(order.payments.first.amount).to eq 100
          end

          # see associated comment in order_decorator#add_store_credit_payments
          context "the store credit is already in the pending state" do
            before do
              order.payments.store_credits.last.authorize!
              order.add_store_credit_payments
            end

            it "charges the outstanding balance to the credit card" do
              expect(order.errors.messages).to be_empty
              expect(order.payments.count).to eq 2
              expect(order.payments.first.source).to be_a(Spree::CreditCard)
              expect(order.payments.first.amount).to eq 100
            end
          end
        end
      end

      context "there are multiple store credits" do
        context "they have different credit type priorities" do
          let(:amount_difference)       { 100 }
          let!(:primary_store_credit)   { create(:store_credit, amount: (order_total - amount_difference)) }
          let!(:secondary_store_credit) { create(:store_credit, amount: order_total, user: primary_store_credit.user, credit_type: create(:secondary_credit_type)) }
          let(:order) { create(:order_with_totals, user: primary_store_credit.user, line_items_price: order_total).tap(&:update!) }

          before do
            subject
            order.reload
          end

          it "uses the primary store credit type over the secondary" do
            primary_payment = order.payments.detect{ |x| x.source == primary_store_credit }
            secondary_payment = order.payments.detect{ |x| x.source == secondary_store_credit }

            expect(order.payments.size).to eq 2
            expect(primary_payment.source).to eq primary_store_credit
            expect(secondary_payment.source).to eq secondary_store_credit
            expect(primary_payment.amount).to eq(order_total - amount_difference)
            expect(secondary_payment.amount).to eq(amount_difference)
          end
        end
      end
    end

    describe "#covered_by_store_credit" do
      context "order doesn't have an associated user" do
        subject { create(:order, user: nil) }

        it "returns false" do
          expect(subject.covered_by_store_credit).to be false
        end
      end

      context "order has an associated user" do
        let(:user) { create(:user) }

        subject    { create(:order, user: user) }

        context "user has enough store credit to pay for the order" do
          before do
            allow(user).to receive_messages(total_available_store_credit: 10.0)
            allow(subject).to receive_messages(total: 5.0)
          end

          it "returns true" do
            expect(subject.covered_by_store_credit).to be true
          end
        end

        context "user does not have enough store credit to pay for the order" do
          before do
            allow(user).to receive_messages(total_available_store_credit: 0.0)
            allow(subject).to receive_messages(total: 5.0)
          end

          it "returns false" do
            expect(subject.covered_by_store_credit).to be false
          end
        end
      end
    end

    describe "#total_available_store_credit" do
      context "order does not have an associated user" do
        subject { create(:order, user: nil) }

        it "returns 0" do
          expect(subject.total_available_store_credit).to be_zero
        end
      end

      context "order has an associated user" do
        let(:user)                   { create(:user) }
        let(:available_store_credit) { 25.0 }

        subject { create(:order, user: user) }

        before do
          allow(user).to receive_messages(total_available_store_credit: available_store_credit)
        end

        it "returns the user's available store credit" do
          expect(subject.total_available_store_credit).to eq available_store_credit
        end
      end
    end

    describe "#order_total_after_store_credit" do
      let(:order_total) { 100.0 }

      subject { create(:order, total: order_total) }

      before do
        allow(subject).to receive_messages(total_applicable_store_credit: applicable_store_credit)
      end

      context "order's user has store credits" do
        let(:applicable_store_credit) { 10.0 }

        it "deducts the applicable store credit" do
          expect(subject.order_total_after_store_credit).to eq(order_total - applicable_store_credit)
        end
      end

      context "order's user does not have any store credits" do
        let(:applicable_store_credit) { 0.0 }

        it "returns the order total" do
          expect(subject.order_total_after_store_credit).to eq order_total
        end
      end
    end

    describe "#total_applicable_store_credit" do
      context "order is in the confirm state" do
        before { order.update_attributes(state: 'confirm') }
        include_examples "check total store credit from payments"
      end

      context "order is completed" do
        before { order.update_attributes(state: 'complete') }
        include_examples "check total store credit from payments"
      end

      context "order is in any state other than confirm or complete" do
        context "the associated user has store credits" do
          let(:store_credit) { create(:store_credit) }
          let(:order)        { create(:order, user: store_credit.user) }

          subject { order }

          context "the store credit is more than the order total" do
            let(:order_total) { store_credit.amount - 1 }

            before { order.update_attributes(total: order_total) }

            it "returns the order total" do
              expect(subject.total_applicable_store_credit).to eq order_total
            end
          end

          context "the store credit is less than the order total" do
            let(:order_total) { store_credit.amount * 10 }

            before { order.update_attributes(total: order_total) }

            it "returns the store credit amount" do
              expect(subject.total_applicable_store_credit).to eq store_credit.amount
            end
          end
        end

        context "the associated user does not have store credits" do
          let(:order) { create(:order) }

          subject { order }

          it "returns 0" do
            expect(subject.total_applicable_store_credit).to be_zero
          end
        end

        context "the order does not have an associated user" do
          subject { create(:order, user: nil) }

          it "returns 0" do
            expect(subject.total_applicable_store_credit).to be_zero
          end
        end
      end
    end

    describe "#display_total_applicable_store_credit" do
      let(:total_applicable_store_credit) { 10.00 }

      subject { create(:order) }

      before { allow(subject).to receive_messages(total_applicable_store_credit: total_applicable_store_credit) }

      it "returns a money instance" do
        expect(subject.display_total_applicable_store_credit).to be_a(Spree::Money)
      end

      it "returns a negative amount" do
        expect(subject.display_total_applicable_store_credit.money.cents).to eq(total_applicable_store_credit * -100.0)
      end
    end

    describe "#display_order_total_after_store_credit" do
      let(:order_total_after_store_credit) { 10.00 }

      subject { create(:order) }

      before { allow(subject).to receive_messages(order_total_after_store_credit: order_total_after_store_credit) }

      it "returns a money instance" do
        expect(subject.display_order_total_after_store_credit).to be_a(Spree::Money)
      end

      it "returns the order_total_after_store_credit amount" do
        expect(subject.display_order_total_after_store_credit.money.cents).to eq(order_total_after_store_credit * 100.0)
      end
    end

    describe "#display_total_available_store_credit" do
      let(:total_available_store_credit) { 10.00 }

      subject { create(:order) }

      before { allow(subject).to receive_messages(total_available_store_credit: total_available_store_credit) }

      it "returns a money instance" do
        expect(subject.display_total_available_store_credit).to be_a(Spree::Money)
      end

      it "returns the total_available_store_credit amount" do
        expect(subject.display_total_available_store_credit.money.cents).to eq(total_available_store_credit * 100.0)
      end
    end

    describe "#display_store_credit_remaining_after_capture" do
      let(:total_available_store_credit)  { 10.00 }
      let(:total_applicable_store_credit) { 5.00 }

      subject { create(:order) }

      before do
        allow(subject).to receive_messages(total_available_store_credit: total_available_store_credit,
                     total_applicable_store_credit: total_applicable_store_credit)
      end

      it "returns a money instance" do
        expect(subject.display_store_credit_remaining_after_capture).to be_a(Spree::Money)
      end

      it "returns all of the user's available store credit minus what's applied to the order amount" do
        amount_remaining = total_available_store_credit - total_applicable_store_credit
        expect(subject.display_store_credit_remaining_after_capture.money.cents).to eq(amount_remaining * 100.0)
      end
    end

    context 'when not capturing at order completion' do
      let!(:store_credit_payment_method) do
        create(
          :store_credit_payment_method,
          auto_capture: false, # not capturing at completion time
        )
      end

      describe '#after_cancel' do
        let(:user) { create(:user) }
        let!(:store_credit) do
          create(:store_credit, amount: 100, user: user)
        end
        let(:order) do
          create(
            :order_with_line_items,
            user: user,
            line_items_count: 1,
            # order will be $20 total:
            line_items_price: 10,
            shipment_cost: 10
          )
        end

        before do
          order.contents.advance
          order.complete!
        end

        it 'releases the pending store credit authorization' do
          expect {
            order.cancel!
          }.to change {
            store_credit.reload.amount_authorized
          }.from(20).to(0)

          expect(store_credit.amount_remaining).to eq 100
        end
      end
    end
  end
end

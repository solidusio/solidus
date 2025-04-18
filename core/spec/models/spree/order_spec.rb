# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:store) { create(:store) }
  let(:user) { create(:user, email: "solidus@example.com") }
  let(:order) { create(:order, user:, store:) }

  describe ".ransackable_associations" do
    subject { described_class.ransackable_associations }

    it { is_expected.to contain_exactly("user", "line_items", "shipments", "bill_address", "ship_address") }
  end

  describe ".line_item_comparison_hooks=" do
    it "allows setting the line item comparison hooks but emits a deprecation message" do
      expect(Spree::Config).to receive(:line_item_comparison_hooks=).with([:foos_match])
      expect(Spree.deprecator).to receive(:warn)
        .with(
          "line_item_comparison_hooks= is deprecated and will be removed from Solidus 5.0 (Use Spree::Config.line_item_comparison_hooks instead.)",
          an_instance_of(Array)
        )
      described_class.line_item_comparison_hooks = [:foos_match]
    end
  end

  describe ".line_item_comparison_hooks" do
    before do |example|
      stub_spree_preferences(line_item_comparison_hooks: [:foos_match])
    end

    it "allows getting the comparison hooks but emits a deprecation message" do
      expect(Spree.deprecator).to receive(:warn)
        .with(
          "line_item_comparison_hooks is deprecated and will be removed from Solidus 5.0 (Use Spree::Config.line_item_comparison_hooks instead.)",
          an_instance_of(Array)
        )
      described_class.line_item_comparison_hooks
    end
  end

  describe ".register_line_item_comparison_hook" do
    after do
      expect(Spree::Config.line_item_comparison_hooks).to be_empty
    end
    it "allows setting the line item comparison hooks but emits a deprecation message" do
      expect(Spree::Config.line_item_comparison_hooks).to receive(:<<).with(:foos_match)

      expect(Spree.deprecator).to receive(:warn)
        .with(
          "register_line_item_comparison_hook is deprecated and will be removed from Solidus 5.0 (Use Spree::Config.line_item_comparison_hooks instead.)",
          an_instance_of(Array)
        )
      Spree::Order.register_line_item_comparison_hook(:foos_match)
    end
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
    subject { order.cancel! }

    let!(:order) { create(:completed_order_with_totals) }

    it "publishes a 'order_canceled' event" do
      stub_spree_bus

      subject

      expect(:order_canceled).to have_been_published.with(order:)
    end

    it "sends a cancel email" do
      perform_enqueued_jobs { subject }

      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to include "Cancellation"
    end

    context 'when the payment is completed' do
      let(:order) { create(:order_ready_to_ship) }
      let(:payment) { order.payments.first }

      it 'does not change the payment state' do
        expect { subject }.not_to change { payment.reload.state }
      end

      it 'refunds the payment' do
        expect { subject }.to change { Spree::Refund.count }.by(1)
      end

      it "cancels the order" do
        expect{ subject }.to change{ order.can_cancel? }.from(true).to(false)
        expect(order).to be_canceled
      end

      it 'saves canceled_at' do
        subject
        expect(order.reload.canceled_at).to_not be_nil
      end

      it "places the order into the canceled scope" do
        expect{ subject }.to change{ Spree::Order.canceled.include?(order) }.from(false).to(true)
      end

      it "removes the order from the not_canceled scope" do
        expect{ subject }.to change{ Spree::Order.not_canceled.include?(order) }.from(true).to(false)
      end
    end

    context "when the payment is fully refunded" do
      let(:order) { create(:completed_order_with_totals) }
      let(:payment_amount) { 50 }
      let(:payment) { create(:payment, order:, amount: payment_amount, state: 'completed') }

      it "cancels the order" do
        create(:refund, payment:, amount: payment_amount)

        expect{ subject }.to change{ order.can_cancel? }.from(true).to(false)
        expect(order).to be_canceled
      end
    end

    context 'when the payment is pending' do
      let(:order) { create(:completed_order_with_pending_payment) }
      let(:payment) { order.payments.first }

      it 'voids the pending payment' do
        expect { subject }.to change { payment.reload.state }.from('pending').to('void')
      end
    end

    context 'when the payment is failed' do
      let(:order) { create(:completed_order_with_pending_payment) }
      let(:payment) { order.payments.first.tap(&:failure!) }

      it 'does not change the payment state' do
        expect { subject }.not_to change { payment.reload.state }
      end
    end

    context "when shipment is shipped" do
      let!(:order) { create(:shipped_order) }

      it "fails" do
        expect(order.payments.first).to_not receive(:cancel!)

        expect { subject }.to raise_error(StateMachines::InvalidTransition)
      end
    end

    context 'with a store credit payment' do
      let(:order) { create(:completed_order_with_totals) }
      let(:payment) { create(:store_credit_payment, amount: order.total, order:) }

      context 'when the payment is pending' do
        let(:store_credit) { payment.source }

        before do
          payment.authorize!
        end

        it 'voids the payment' do
          expect { subject }.to change { payment.reload.state }.from('pending').to('void')
        end

        it 'releases the pending store credit authorization' do
          expect { subject }.to change { store_credit.reload.amount_authorized }.from(110).to(0)
        end
      end

      context 'when the payment is completed' do
        before do
          payment.purchase!
        end

        it 'refunds the payment' do
          expect { subject }.to change { Spree::Refund.count }.by(1)
        end
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
        order.line_items.first.variant.discard
      end

      it 'should restart checkout flow' do
        expect(order).to receive(:restart_checkout_flow).once
        subject
      end

      it 'should have error message' do
        subject
        expect(order.errors[:base]).to include(I18n.t('spree.deleted_variants_present'))
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
      create(:line_item, order:)
      create(:shipment, order:)
      create(:adjustment, source: nil, adjustable: order, order:)
      order.recalculate

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

  context '#outstanding_balance' do
    let(:order) { create(:order_ready_to_ship, line_items_count: 3) }
    let(:payment) { order.payments.first }

    it "should handle refunds properly" do
      order.cancellations.short_ship([order.inventory_units.first])
      expect(order.outstanding_balance).to be_negative
      expect(order.payment_state).to eq('credit_owed')
      create(:refund, amount: order.outstanding_balance.abs, payment:, transaction_id: nil).perform!
      order.reload
      expect(order.outstanding_balance).to eq(0)
      expect(order.payment_state).to eq('paid')
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

  describe "#promo_total" do
    it "returns the value as a spree money" do
      order.promo_total = 10.55
      expect(order.display_promo_total).to eq(Spree::Money.new(10.55))
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

  describe "#ensure_updated_shipments" do
    let(:order) { create(:order) }
    let(:subject) { order.ensure_updated_shipments }

    it "is deprecated" do
      expect(Spree.deprecator).to receive(:warn).with(/ensure_updated_shipments is deprecated.*use check_shipments_and_restart_checkout instead/, any_args)

      subject
    end
  end

  context "ensure shipments will be updated" do
    subject(:order) { create :order }
    before do
      Spree::Shipment.create!(order:)
    end

    ['payment', 'confirm'].each do |order_state|
      context "when ther order is in the #{order_state} state" do
        before do
          order.state = order_state
          order.shipments.create!
        end

        it "destroys current shipments" do
          order.check_shipments_and_restart_checkout
          expect(order.shipments).to be_empty
        end

        it "puts order back in cart state" do
          order.check_shipments_and_restart_checkout
          expect(order.state).to eql "cart"
        end

        it "resets shipment_total" do
          order.update_column(:shipment_total, 5)
          order.check_shipments_and_restart_checkout
          expect(order.shipment_total).to eq(0)
        end

        it "does nothing if any shipments are ready" do
          shipment = create(:shipment, order: subject, state: "ready")
          expect { subject.check_shipments_and_restart_checkout }.not_to change { subject.reload.shipments.pluck(:id) }
          expect { shipment.reload }.not_to raise_error
        end

        it "does nothing if any shipments are shipped" do
          shipment = create(:shipment, order: subject, state: "shipped")
          expect { subject.check_shipments_and_restart_checkout }.not_to change { subject.reload.shipments.pluck(:id) }
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
        order.check_shipments_and_restart_checkout
        expect(order.shipments).to be_empty
      end

      it "resets shipment_total" do
        order.update_column(:shipment_total, 5)
        order.check_shipments_and_restart_checkout
        expect(order.shipment_total).to eq(0)
      end

      it "puts the order in the cart state" do
        order.check_shipments_and_restart_checkout
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
          order.check_shipments_and_restart_checkout
        }.not_to change { order.shipments }
      end

      it "does not reset the shipment total" do
        expect {
          order.check_shipments_and_restart_checkout
        }.not_to change { order.shipment_total }
      end

      it "does not put the order back in the address state" do
        expect {
          order.check_shipments_and_restart_checkout
        }.not_to change { order.state }
      end
    end

    context "except when order is completed, that's OrderInventory job" do
      it "doesn't touch anything" do
        allow(order).to receive_messages completed?: true
        order.update_column(:shipment_total, 5)
        order.shipments.create!

        expect {
          order.check_shipments_and_restart_checkout
        }.not_to change { order.shipment_total }

        expect {
          order.check_shipments_and_restart_checkout
        }.not_to change { order.shipments }

        expect {
          order.check_shipments_and_restart_checkout
        }.not_to change { order.state }
      end
    end
  end

  describe "#tax_address" do
    let(:order) { build(:order, ship_address:, bill_address:, store:) }
    let(:store) { build(:store) }

    before { stub_spree_preferences(tax_using_ship_address:) }
    subject { order.tax_address }

    context "when the order has no addresses" do
      let(:ship_address) { nil }
      let(:bill_address) { nil }

      context "when tax_using_ship_address is true" do
        let(:tax_using_ship_address) { true }

        context "when the order is associated with a store" do
          it 'returns the stores default cart tax location' do
            expect(subject).to eq(store.default_cart_tax_location)
          end
        end

        context "when the order is not associated with a store" do
          let(:store) { nil }

          it { is_expected.to be_nil }
        end
      end

      context "when tax_using_ship_address is not true" do
        let(:tax_using_ship_address) { false }

        context "when the order is associated with a store" do
          it 'returns the stores default cart tax location' do
            expect(subject).to eq(store.default_cart_tax_location)
          end
        end

        context "when the order is not associated with a store" do
          let(:store) { nil }

          it { is_expected.to be_nil }
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
      expect(order.checkout_steps).to eql %w(address delivery payment confirm complete)
      expect{ order.restart_checkout_flow }.to change{ order.state }.from("delivery").to("address")
    end

    context "when the order cannot advance from cart state" do
      around do |example|
        Spree::Order.state_machine.before_transition to: :address, do: -> { false }
        example.run
        Spree::Order.define_state_machine!
      end

      it "leaves the order in cart state" do
        order = create(:order_with_totals, state: "delivery")
        expect{ order.restart_checkout_flow }.to change { order.state }.from("delivery").to("cart")
      end
    end

    context "without line items" do
      let(:order) { create(:order, state: "delivery", line_items: []) }

      it "updates the state column to cart" do
        expect{ order.restart_checkout_flow }.to change{ order.state }.from("delivery").to("cart")
      end

      it "doesn't add errors to the order" do
        order.restart_checkout_flow

        expect(order.errors).to be_empty
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4199
  context "#available_payment_methods" do
    it "includes frontend payment methods" do
      payment_method = Spree::PaymentMethod::Check.create!({
        name: "Fake",
        active: true,
        available_to_users: true,
        available_to_admin: false
      })
      expect(order.available_payment_methods).to include(payment_method)
    end

    it "includes 'both' payment methods" do
      payment_method = Spree::PaymentMethod::Check.create!({
        name: "Fake",
        active: true,
        available_to_users: true,
        available_to_admin: true
      })
      expect(order.available_payment_methods).to include(payment_method)
    end

    it "does not include a payment method twice" do
      payment_method = Spree::PaymentMethod::Check.create!({
        name: "Fake",
        active: true,
        available_to_users: true,
        available_to_admin: true
      })
      expect(order.available_payment_methods.count).to eq(1)
      expect(order.available_payment_methods).to include(payment_method)
    end

    it "does not include inactive payment methods" do
      Spree::PaymentMethod::Check.create!({
        name: "Fake",
        active: false,
        available_to_users: true,
        available_to_admin: true
      })
      expect(order.available_payment_methods.count).to eq(0)
    end

    context "with more than one payment method" do
      subject { order.available_payment_methods }

      let!(:first_method) {
        FactoryBot.create(:payment_method, available_to_users: true,
                                               available_to_admin: true)
      }
      let!(:second_method) {
        FactoryBot.create(:payment_method, available_to_users: true,
                                               available_to_admin: true)
      }

      before do
        second_method.move_to_top
      end

      it "respects the order of methods based on position" do
        expect(subject).to eq([second_method, first_method])
      end
    end

    context 'when the order has a store' do
      let(:order) { create(:order) }

      let!(:store_with_payment_methods) do
        create(:store,
          payment_methods: [payment_method_with_store])
      end
      let!(:payment_method_with_store) { create(:payment_method) }
      let!(:store_without_payment_methods) { create(:store) }
      let!(:payment_method_without_store) { create(:payment_method) }

      context 'when the store has payment methods' do
        before { order.update!(store: store_with_payment_methods) }

        it 'returns only the matching payment methods for that store' do
          expect(order.available_payment_methods).to match_array(
            [payment_method_with_store]
          )
        end

        context 'and the store has an extra payment method unavailable to users' do
          let!(:admin_only_payment_method) do
            create(:payment_method,
                                                     available_to_users: false,
                                                     available_to_admin: true)
          end

          before do
            store_with_payment_methods.payment_methods << admin_only_payment_method
          end

          it 'returns only the payment methods available to users for that store' do
            expect(order.available_payment_methods).to match_array(
              [payment_method_with_store]
            )
          end
        end
      end

      context 'when the store does not have payment methods' do
        before { order.update!(store: store_without_payment_methods) }

        it 'returns all matching payment methods regardless of store' do
          expect(order.available_payment_methods).to match_array(
            [payment_method_with_store, payment_method_without_store]
          )
        end
      end
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

    context "match line item with options", partial_double_verification: false do
      before do
        stub_spree_preferences(line_item_comparison_hooks: [:foos_match])
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

  describe "#generate_order_number" do
    let(:order) { build(:order) }

    context "with default app configuration" do
      it 'calls the default order number generator' do
        expect_any_instance_of(Spree::Order::NumberGenerator).to receive(:generate)
        order.generate_order_number
      end
    end

    context "with order number generator configured" do
      class TruthNumberGenerator
        def initialize(options = {}); end

        def generate
          '42'
        end
      end

      before do
        expect(Spree::Config).to receive(:order_number_generator) do
          TruthNumberGenerator.new
        end
      end

      it 'calls the configured order number generator' do
        order.generate_order_number
        expect(order.number).to eq '42'
      end
    end

    context "with number already present" do
      before do
        order.number = '123'
      end

      it 'does not generate new number' do
        order.generate_order_number
        expect(order.number).to eq '123'
      end
    end
  end

  context "#associate_user!" do
    let!(:user) { FactoryBot.create(:user) }

    it "should associate a user with a persisted order" do
      order = FactoryBot.create(:order_with_line_items, created_by: nil)
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
      order = FactoryBot.create(:order_with_line_items, created_by: creator)

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

  context "#assign_default_user_addresses" do
    let(:order) { Spree::Order.new }

    subject { order.assign_default_user_addresses }

    context "when no user is associated to the order" do
      it "does not associate any bill address" do
        expect { subject }.not_to change { order.bill_address }.from(nil)
      end

      it "does not associate any ship address" do
        expect { subject }.not_to change { order.ship_address }.from(nil)
      end
    end

    context "when user is associated to the order" do
      let(:user)         { build_stubbed(:user) }
      let(:bill_address) { nil }
      let(:ship_address) { nil }

      before do
        order.associate_user!(user)
        user.bill_address = bill_address
        user.ship_address = ship_address
      end

      context "but has no bill address associated" do
        it "does not associate any bill address" do
          expect { subject }.not_to change { order.bill_address }.from(nil)
        end
      end

      context "and has an invalid bill address associated " do
        let(:bill_address) { build(:address, city: nil) } # invalid address

        it "does not associate any bill address" do
          expect { subject }.not_to change { order.bill_address }.from(nil)
        end
      end

      context "and has a valid address associated " do
        let(:bill_address) { build(:address) }

        it "does associate user bill address" do
          expect { subject }.to change { order.bill_address }.from(nil).to(bill_address)
        end
      end

      context "but has no ship address associated" do
        it "does not associate any ship address" do
          expect { subject }.not_to change { order.ship_address }.from(nil)
        end
      end

      context "and has an invalid ship address associated " do
        let(:ship_address) { build(:address, city: nil) } # invalid address

        it "does not associate any ship address" do
          expect { subject }.not_to change { order.ship_address }.from(nil)
        end
      end

      context "and has a valid ship address associated" do
        let(:ship_address) { build(:address) }

        it "does associate user ship address" do
          expect { subject }.to change { order.ship_address }.from(nil).to(ship_address)
        end

        context 'when checkout step does not include delivery' do
          before do
            expect(order).to receive(:checkout_steps) { %w[some step] }
          end

          it "does not associate any ship address" do
            expect { subject }.not_to change { order.ship_address }.from(nil)
          end
        end
      end
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
      @order = create(:order, user:)
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

  describe "#item_total_excluding_vat" do
    it "sums all of the line items' pre tax amounts" do
      subject.line_items = [
        Spree::LineItem.new(price: 10, quantity: 2, included_tax_total: 15.0),
        Spree::LineItem.new(price: 30, quantity: 1, included_tax_total: 16.0)
      ]
      # (2*10)-15 + 30-16 = 5 + 14 = 19
      expect(subject.item_total_excluding_vat).to eq 19.0
      expect(subject.display_item_total_excluding_vat).to eq Spree::Money.new(19)
    end
  end

  describe "#item_total_before_tax" do
    it "sums all of the line items totals before tax" do
      subject.line_items = [
        Spree::LineItem.new(price: 10, quantity: 2, included_tax_total: 15.0).tap do |li|
          li.adjustments.build(amount: -2)
        end,
        Spree::LineItem.new(price: 30, quantity: 1, included_tax_total: 16.0).tap do |li|
          li.adjustments.build(amount: -3)
        end
      ]
      # (2*10)-2 + 30-3 = 18 + 27 = 14
      expect(subject.item_total_before_tax).to eq 45.0
      expect(subject.display_item_total_before_tax).to eq Spree::Money.new(45)
    end
  end

  describe "#shipment_total_before_tax" do
    it "sums all of the line items totals before tax" do
      subject.shipments = [
        Spree::Shipment.new(cost: 20, included_tax_total: 15.0).tap do |li|
          li.adjustments.build(amount: -2)
        end,
        Spree::Shipment.new(cost: 30, included_tax_total: 16.0).tap do |li|
          li.adjustments.build(amount: -3)
        end
      ]
      # 20-2 + 30-3 = 18 + 27 = 14
      expect(subject.shipment_total_before_tax).to eq 45.0
      expect(subject.display_shipment_total_before_tax).to eq Spree::Money.new(45)
    end
  end

  context "#refund_total" do
    let(:order) { create(:order_with_line_items) }
    let!(:payment) { create(:payment_with_refund, order:, amount: 5, refund_amount: 3) }
    let!(:payment2) { create(:payment_with_refund, order:, amount: 5, refund_amount: 2.5) }

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
      allow_any_instance_of(Spree::Stock::SimpleCoordinator).to receive(:shipments).and_return([shipment])
      subject.create_proposed_shipments
      expect(subject.shipments).to eq [shipment]
    end

    it "raises an error if any shipments are ready" do
      shipment = create(:shipment, order: subject, state: "ready")

      expect {
        expect {
          subject.create_proposed_shipments
        }.to raise_error(Spree::Order::CannotRebuildShipments)
      }.not_to change { subject.reload.shipments.pluck(:id) }

      expect { shipment.reload }.not_to raise_error
    end

    it "raises an error if any shipments are shipped" do
      shipment = create(:shipment, order: subject, state: "shipped")
      expect {
        expect {
          subject.create_proposed_shipments
        }.to raise_error(Spree::Order::CannotRebuildShipments)
      }.not_to change { subject.reload.shipments.pluck(:id) }

      expect { shipment.reload }.not_to raise_error
    end

    context "when the order is already completed" do
      let(:order) { create(:completed_order_with_pending_payment) }

      it "raises an error" do
        expect {
          order.create_proposed_shipments
        }.to raise_error(Spree::Order::CannotRebuildShipments)
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

    context "all inventory units are returned on the database (e.g. through another association)" do
      it "is true" do
        expect {
          Spree::InventoryUnit
            .where(id: order.inventory_unit_ids)
            .update_all(state: 'returned')
        }.to change {
          order.all_inventory_units_returned?
        }.from(false).to(true)
      end
    end
  end

  context "store credit" do
    shared_examples "check total store credit from payments" do
      context "with valid payments" do
        let(:order)           { payment.order }
        let!(:payment)        { create(:store_credit_payment) }
        let!(:second_payment) { create(:store_credit_payment, order:) }

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
          let!(:cc_payment) { create(:payment, order:, amount: order_total) }

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

      context 'there is store credit in another currency' do
        let(:order) { create(:order_with_totals, user:, line_items_price: order_total).tap(&:recalculate) }
        let!(:store_credit_usd) { create(:store_credit, user:, amount: 1, currency: 'USD') }
        let!(:store_credit_gbp) { create(:store_credit, user:, amount: 1, currency: 'GBP') }
        let(:user) { create(:user) }

        it 'only adds the credit in the matching currency' do
          expect {
            order.add_store_credit_payments
          }.to change {
            order.payments.count
          }.by(1)

          applied_store_credits = order.payments.store_credits.map(&:source)
          expect(applied_store_credits).to match_array([store_credit_usd])
        end
      end

      context "there is enough store credit to pay for the entire order" do
        let(:store_credit) { create(:store_credit, amount: order_total) }
        let(:order) { create(:order_with_totals, user: store_credit.user, line_items_price: order_total).tap(&:recalculate) }

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
            cc_payment = create(:payment, order:)
            expect { subject }.to change { cc_payment.reload.state }.to 'invalid'
          end
        end
      end

      context "the available store credit is not enough to pay for the entire order" do
        let(:order_total) { 500 }
        let(:store_credit_total) { order_total - 100 }
        let(:store_credit)       { create(:store_credit, amount: store_credit_total) }
        let(:order) { create(:order_with_totals, user: store_credit.user, line_items_price: order_total).tap(&:recalculate) }

        context "there are no other payments" do
          it "adds an error to the model" do
            expect(subject).to be false
            expect(order.errors.full_messages).to include(I18n.t('spree.store_credit.errors.unable_to_fund'))
          end
        end

        context "there is a completed credit card payment" do
          let!(:cc_payment) { create(:payment, order:, state: "completed", amount: 100) }

          it "successfully creates the store credit payments" do
            expect { subject }.to change { order.payments.count }.from(1).to(2)
            expect(order.errors).to be_empty
          end
        end

        context "there is a credit card payment" do
          let!(:cc_payment) { create(:payment, order:, state: "checkout") }

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
          let(:order) { create(:order_with_totals, user: primary_store_credit.user, line_items_price: order_total).tap(&:recalculate) }

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
      subject do
        order.covered_by_store_credit
      end

      let(:order) { create(:order_with_line_items, user:, store:) }

      context "order doesn't have an associated user" do
        let(:user) { nil }
        it { is_expected.to eq(false) }
      end

      context "order has an associated user" do
        context "user has enough store credit to pay for the order" do
          let!(:credit) { create(:store_credit, user:, amount: 1000) }
          it { is_expected.to eq(true) }
        end

        context "user does not have enough store credit to pay for the order" do
          let!(:credit) { create(:store_credit, user:, amount: 1) }
          it { is_expected.to eq(false) }
        end
      end
    end

    describe "#total_available_store_credit" do
      subject do
        order.total_available_store_credit
      end

      context "order does not have an associated user" do
        let(:user) { nil }
        it { is_expected.to eq(0) }
      end

      context "order has an associated user" do
        let!(:credit) { create(:store_credit, user:, amount: 25) }
        it { is_expected.to eq(25) }
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
        before { order.update(state: 'confirm') }
        include_examples "check total store credit from payments"
      end

      context "order is completed" do
        before { order.update(state: 'complete') }
        include_examples "check total store credit from payments"
      end

      context "order is in any state other than confirm or complete" do
        context "the associated user has store credits" do
          let(:store_credit) { create(:store_credit) }
          let(:order)        { create(:order, user: store_credit.user) }

          subject { order }

          context "the store credit is more than the order total" do
            let(:order_total) { store_credit.amount - 1 }

            before { order.update(total: order_total) }

            it "returns the order total" do
              expect(subject.total_applicable_store_credit).to eq order_total
            end
          end

          context "the store credit is less than the order total" do
            let(:order_total) { store_credit.amount * 10 }

            before { order.update(total: order_total) }

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

      before { allow(subject).to receive_messages(total_applicable_store_credit:) }

      it "returns a money instance" do
        expect(subject.display_total_applicable_store_credit).to be_a(Spree::Money)
      end

      it "returns a negative amount" do
        expect(subject.display_total_applicable_store_credit.money.cents).to eq(total_applicable_store_credit * -100.0)
      end
    end

    describe "#record_ip_address" do
      let(:ip_address) { "127.0.0.1" }

      subject { order.record_ip_address(ip_address) }

      it "updates the last used IP address" do
        expect { subject }.to change(order, :last_ip_address).to(ip_address)
      end

      # IP address tracking should not raise validation exceptions
      context "with an invalid order" do
        before { allow(order).to receive(:valid?).and_return(false) }

        it "updates the IP address" do
          expect { subject }.to change(order, :last_ip_address).to(ip_address)
        end
      end

      context "with a new order" do
        let(:order) { build(:order) }

        it "updates the IP address" do
          expect { subject }.to change(order, :last_ip_address).to(ip_address)
        end
      end
    end

    describe "#display_order_total_after_store_credit" do
      let(:order_total_after_store_credit) { 10.00 }

      subject { create(:order) }

      before { allow(subject).to receive_messages(order_total_after_store_credit:) }

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

      before { allow(subject).to receive_messages(total_available_store_credit:) }

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
        allow(subject).to receive_messages(total_available_store_credit:,
                     total_applicable_store_credit:)
      end

      it "returns a money instance" do
        expect(subject.display_store_credit_remaining_after_capture).to be_a(Spree::Money)
      end

      it "returns all of the user's available store credit minus what's applied to the order amount" do
        amount_remaining = total_available_store_credit - total_applicable_store_credit
        expect(subject.display_store_credit_remaining_after_capture.money.cents).to eq(amount_remaining * 100.0)
      end
    end
  end

  describe "#validate_payments_attributes" do
    let(:attributes) { [ActionController::Parameters.new(payment_method_id: payment_method.id)] }
    subject do
      order.validate_payments_attributes(attributes)
    end

    context "with empty array" do
      let(:attributes) { [] }
      it "doesn't error" do
        subject
      end
    end

    context "with no payment method specified" do
      let(:attributes) { [ActionController::Parameters.new({})] }
      it "doesn't error" do
        subject
      end
    end

    context "with valid payment method" do
      let(:payment_method) { create(:check_payment_method) }
      it "doesn't error" do
        subject
      end
    end

    context "with inactive payment method" do
      let(:payment_method) { create(:check_payment_method, active: false) }

      it "raises RecordNotFound" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with unavailable payment method" do
      let(:payment_method) { create(:check_payment_method, available_to_users: false) }

      it "raises RecordNotFound" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with soft-deleted payment method" do
      let(:payment_method) { create(:check_payment_method, deleted_at: Time.current) }

      it "raises RecordNotFound" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#create_shipments_for_line_item' do
    subject { order.create_shipments_for_line_item(line_item) }

    let(:order) { create :order, shipments: [] }
    let(:line_item) { build(:line_item, order:) }

    it 'creates at least one new shipment for the order' do
      expect { subject }.to change { order.shipments.count }.from(0).to(1)
    end

    context "with a custom inventory unit builder" do
      before do
        # Because the defined method runs in the context of the instance of our
        # test inventory unit builder, not the RSpec example context, we need
        # to make this value available as a local variable. We're using
        # Class.new and define_method to avoid creating scope gates that would
        # take this local variable out of scope.
        inventory_unit = arbitrary_inventory_unit
        TestInventoryUnitBuilder = Class.new do
          def initialize(order)
          end

          define_method(:missing_units_for_line_item) { |line_item|
            [inventory_unit]
          }
        end

        test_stock_config = Spree::Core::StockConfiguration.new
        test_stock_config.inventory_unit_builder_class = TestInventoryUnitBuilder.to_s
        stub_spree_preferences(stock: test_stock_config)
      end

      after do
        Object.send(:remove_const, :TestInventoryUnitBuilder)
      end

      let(:arbitrary_inventory_unit) { build :inventory_unit, order:, line_item:, variant: line_item.variant }

      it "relies on the custom builder" do
        expect { subject }.to change { order.shipments.count }.from(0).to(1)

        expect(order.shipments.order(:created_at).first.inventory_units)
          .to contain_exactly arbitrary_inventory_unit
      end
    end
  end

  describe '#shipping_discount' do
    let(:shipment) { create(:shipment) }
    let(:order) { shipment.order }

    let!(:charge_shipment_adjustment) { create :adjustment, adjustable: shipment, amount: 20 }
    let!(:shipment_adjustment) { create :adjustment, adjustable: shipment, amount: -10 }
    let!(:other_shipment_adjustment) { create :adjustment, adjustable: shipment, amount: -30 }

    subject { order.shipping_discount }

    it 'sums eligible shipping adjustments with negative amount (credit)' do
      expect(subject).to eq 40
    end
  end

  describe "#ensure_inventory_units" do
    subject { order.send(:ensure_inventory_units) }

    before do
      class TestValidator
        def validate(line_item)
          if line_item.quantity != 1
            line_item.errors.add(:quantity, ":(")
          end
        end
      end

      test_stock_config = Spree::Core::StockConfiguration.new
      test_stock_config.inventory_validator_class = TestValidator.to_s
      stub_spree_preferences(stock: test_stock_config)
    end

    let(:order) { create :order_with_line_items, line_items_count: 2 }

    it "uses the configured validator" do
      expect_any_instance_of(TestValidator).to receive(:validate).twice.and_call_original

      subject
    end

    context "when the line items are valid" do
      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when the line items are not valid" do
      before do
        order.line_items.last.quantity = 2
      end

      it "raises an exception" do
        expect { subject }.to raise_error(Spree::Order::InsufficientStock)
      end
    end
  end

  describe "#validate_line_item_availability" do
    subject { order.send(:validate_line_item_availability) }

    before do
      class TestValidator
        def validate(line_item)
          if line_item.variant.sku == "UNAVAILABLE"
            line_item.errors.add(:quantity, ":(")
            false
          else
            true
          end
        end
      end

      test_stock_config = Spree::Core::StockConfiguration.new
      test_stock_config.availability_validator_class = TestValidator.to_s
      stub_spree_preferences(stock: test_stock_config)
    end

    let(:order) { create :order_with_line_items, line_items_count: 2 }

    context "when the line items are valid" do
      it "doesn't raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when the line items are not valid" do
      before do
        order.line_items.last.variant.sku = "UNAVAILABLE"
      end

      it "raises an exception" do
        expect { subject }.to raise_error(Spree::Order::InsufficientStock)
      end
    end
  end

  describe ".find_by_param" do
    let(:order) { create(:order) }
    let(:param) { order.number }

    subject { Spree::Order.find_by_param(param) }

    it "finds the order" do
      expect(subject).to eq(order)
    end

    context "with a non-existent order" do
      let(:param) { "non-existent" }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe ".find_by_param!" do
    let(:order) { create(:order) }
    let(:param) { order.number }

    subject { Spree::Order.find_by_param!(param) }

    it "finds the order" do
      expect(subject).to eq(order)
    end

    context "with a non-existent order" do
      let(:param) { "non-existent" }

      it "returns nil" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe ".by_customer" do
    let(:user) { create(:user, email: "customer@example.com") }
    let!(:order) { create(:order, user:) }
    let!(:other_order) { create(:order) }
    let(:email) { user.email }

    subject { Spree::Order.by_customer(email) }

    it "finds the order" do
      expect(subject).to eq([order])
    end

    context "if user has no order" do
      let(:email) { "not_a_customer@example.com" }

      it "returns an empty list" do
        expect(subject).to eq([])
      end
    end
  end

  describe ".by_state" do
    let!(:cart_order) { create(:order, state: :cart) }
    let!(:address_order) { create(:order, state: :address) }
    let!(:complete_order) { create(:order, state: :complete) }

    subject { Spree::Order.by_state(desired_state) }

    context "with a desired state of cart" do
      let(:desired_state) { :cart }

      it "returns the cart order" do
        expect(subject).to eq([cart_order])
      end
    end

    context "with a desired state of address" do
      let(:desired_state) { :address }

      it "returns the address order" do
        expect(subject).to eq([address_order])
      end
    end

    context "with a desired state of complete" do
      let(:desired_state) { :complete }

      it "returns the complete order" do
        expect(subject).to eq([complete_order])
      end
    end

    context "with a desired state of payment" do
      let(:desired_state) { :payment }

      it "returns an empty list" do
        expect(subject).to eq([])
      end
    end
  end

  describe "#to_param" do
    let(:order) { create(:order, number: "MYNUMBER") }

    subject { order.to_param }

    it { is_expected.to eq("MYNUMBER") }
  end

  describe "#shipped_shipments" do
    let(:order) { create(:order, shipments:) }
    let(:shipments) { [shipped_shipment, unshipped_shipment] }
    let(:shipped_shipment) { create(:shipment, state: "shipped") }
    let(:unshipped_shipment) { create(:shipment, state: "ready") }

    subject { order.shipped_shipments }

    it "returns the shipped shipments" do
      expect(subject).to eq([shipped_shipment])
    end
  end

  describe "#name" do
    let(:bill_address) { create(:address, firstname: "John", lastname: "Doe", name: "") }
    let(:ship_address) { create(:address, firstname: "Jane", lastname: "Doe", name: "") }

    let(:order) { create(:order, bill_address:, ship_address:) }

    subject { order.name }

    it { is_expected.to eq("John Doe") }

    context "if bill address is nil" do
      let(:bill_address) { nil }

      it { is_expected.to eq("Jane Doe") }
    end

    context "if both bill address and ship address are nil" do
      let(:bill_address) { nil }
      let(:ship_address) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe "#valid_credit_cards" do
    let(:order) { create(:order, payments: [valid_payment, invalid_payment]) }
    let(:valid_payment) { create(:payment, state: "checkout") }
    let(:invalid_payment) { create(:payment, state: "failed") }

    subject { order.valid_credit_cards }

    it "returns the valid credit cards" do
      expect(subject).to eq([valid_payment.source])
    end
  end

  describe "#coupon_code=" do
    let(:order) { create(:order) }
    let(:promotion) { create(:promotion, code: "10off") }
    let(:coupon_code) { "10OFF" }

    subject { order.coupon_code = coupon_code }

    it "stores the downcased coupon code on the order" do
      expect { subject }.to change { order.coupon_code }.from(nil).to("10off")
    end

    context "with an non-string object" do
      let(:coupon_code) { false }

      it "doesn't store the coupon code on the order" do
        expect { subject }.not_to change { order.coupon_code }.from(nil)
      end
    end
  end

  describe "#refresh_shipment_rates" do
    let(:order) { create(:order, shipments: [shipment_one, shipment_two]) }
    let(:shipment_one) { create(:shipment) }
    let(:shipment_two) { create(:shipment) }

    subject { order.refresh_shipment_rates }

    it "calls #refresh_rates on each shipment" do
      expect(shipment_one).to receive(:refresh_rates)
      expect(shipment_two).to receive(:refresh_rates)

      subject
    end
  end

  describe "#shipping_eq_billing_address?" do
    let(:order) { create(:order, bill_address:, ship_address:) }
    let(:bill_address) { create(:address) }
    let(:ship_address) { create(:address) }

    subject { order.shipping_eq_billing_address? }

    it { is_expected.to eq(false) }

    context "when the addresses are the same" do
      let(:ship_address) { bill_address }

      it { is_expected.to eq(true) }
    end
  end

  describe "#can_approve?" do
    let(:order) { create(:order, approved_at:) }
    let(:approved_at) { nil }

    subject { order.can_approve? }

    it { is_expected.to eq(true) }

    context "when the order is already approved" do
      let(:approved_at) { Time.current }

      it { is_expected.to eq(false) }
    end
  end

  describe "#bill_address_attributes=" do
    let(:order) { create(:order) }
    let(:address_attributes) { { firstname: "Mickey", lastname: "Mouse", name: "Mickey Mouse" } }

    subject { order.bill_address_attributes = address_attributes }

    it "creates a new bill address" do
      subject
      expect(order.bill_address.firstname).to eq("Mickey")
      expect(order.bill_address.lastname).to eq("Mouse")
      expect(order.bill_address.name).to eq("Mickey Mouse")
    end
  end

  describe "#payments_attributes=" do
    let(:order) { create(:order) }
    let(:payment_attributes) { [{ payment_method_id: payment_method.id }] }
    let(:payment_method) { create(:payment_method) }

    subject { order.payments_attributes = payment_attributes }

    it "creates a new payment" do
      expect { subject }.to change { order.payments.length }.from(0).to(1)
    end

    context "if the payment method is unavailable" do
      let(:payment_method) { create(:payment_method, available_to_users: false) }

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#can_add_coupon?" do
    let(:order) { Spree::Order.new }

    subject { order.can_add_coupon? }

    context "when the configured coupon handler allows adding coupons" do
      before do
        expect_any_instance_of(Spree::Config.promotions.coupon_code_handler_class).to receive(:can_apply?).and_return(true)
      end

      it { is_expected.to be true }
    end

    context "when the configured coupon handler does not allow adding coupons" do
      before do
        expect_any_instance_of(Spree::Config.promotions.coupon_code_handler_class).to receive(:can_apply?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe "#shipped?" do
    let(:order) { Spree::Order.new(shipment_state:) }
    let(:shipment_state) { "ready" }

    subject { order.shipped? }

    it { is_expected.to eq(false) }

    context "when the all shipments are shipped" do
      let(:shipment_state) { "shipped" }

      it { is_expected.to eq(true) }
    end

    context "when some shipments are shipped" do
      let(:shipment_state) { "partial" }

      it { is_expected.to eq(true) }
    end
  end

  it_behaves_like "customer and admin metadata fields: storage and validation", :order
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:store) { create(:store) }
  let(:user) { create(:user, email: "spree@example.com") }
  let(:order) { create(:order, user: user, store: store) }
  let(:promotion) do
    FactoryBot.create(
      :promotion,
      :with_order_adjustment,
      code: "discount"
    )
  end
  let(:code) { promotion.codes.first }

  describe '#finalize!' do
    context 'with event notifications' do
      it 'sends an email' do
        expect(Spree::Config.order_mailer_class).to receive(:confirm_email).and_call_original
        order.finalize!
      end

      it 'marks the order as confirmation_delivered' do
        expect do
          order.finalize!
        end.to change(order, :confirmation_delivered).to true
      end

      # These specs show how notifications can be removed, one at a time or
      # all the ones set by MailerSubscriber module
      context 'when removing the default email notification subscription' do
        before do
          Spree::Event.unsubscribe Spree::MailerSubscriber.order_finalized_handler
        end

        after do
          Spree::MailerSubscriber.subscribe!
        end

        it 'does not send the email' do
          expect(Spree::Config.order_mailer_class).not_to receive(:confirm_email)
          order.finalize!
        end
      end

      context 'when removing all the email notification subscriptions' do
        before do
          Spree::MailerSubscriber.unsubscribe!
        end

        after do
          Spree::MailerSubscriber.subscribe!
        end

        it 'does not send the email' do
          expect(Spree::Config.order_mailer_class).not_to receive(:confirm_email)
          order.finalize!
        end
      end
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

      it "cancels the order" do
        expect{ subject }.to change{ order.can_cancel? }.from(true).to(false)
        expect(order).to be_canceled
      end

      it "places the order into the canceled scope" do
        expect{ subject }.to change{ Spree::Order.canceled.include?(order) }.from(false).to(true)
      end

      it "removes the order from the not_canceled scope" do
        expect{ subject }.to change{ Spree::Order.not_canceled.include?(order) }.from(true).to(false)
      end
    end

    context "with fully refunded payment" do
      let(:order) { create(:completed_order_with_totals) }
      let(:payment_amount) { 50 }
      let(:payment) { create(:payment, order: order, amount: payment_amount, state: 'completed') }

      before do
        create(:refund, payment: payment, amount: payment_amount)
      end

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
      expect(order.updater).to receive :update

      Spree::Deprecation.silence do
        order.set_shipments_cost
      end
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
      create(:line_item, order: order)
      create(:shipment, order: order)
      create(:adjustment, adjustable: order, order: order)
      promotion.activate(order: order, promotion_code: code)
      order.recalculate

      # Make sure we are asserting changes
      expect(order.line_items).not_to be_empty
      expect(order.shipments).not_to be_empty
      expect(order.adjustments).not_to be_empty
      expect(order.promotions).not_to be_empty
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
      expect(order.promotions).to be_empty
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
      create(:refund, amount: order.outstanding_balance.abs, payment: payment, transaction_id: nil)
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

  context ".register_update_hook", partial_double_verification: false do
    let(:order) { create(:order) }

    before { Spree::Order.register_update_hook :foo }
    after { Spree::Order.update_hooks.clear }

    it "calls hooks during #recalculate" do
      expect(order).to receive :foo
      order.recalculate
    end

    it "calls hook during #finalize!" do
      expect(order).to receive :foo
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
          expect { subject.ensure_updated_shipments }.not_to change { subject.reload.shipments.pluck(:id) }
          expect { shipment.reload }.not_to raise_error
        end

        it "does nothing if any shipments are shipped" do
          shipment = create(:shipment, order: subject, state: "shipped")
          expect { subject.ensure_updated_shipments }.not_to change { subject.reload.shipments.pluck(:id) }
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

    before { stub_spree_preferences(tax_using_ship_address: tax_using_ship_address) }
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
      expect(order.checkout_steps).to eql %w(address delivery payment confirm complete)
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
    let(:order) { FactoryBot.create(:order) }

    it "logs state changes" do
      order.update_column(:payment_state, 'balance_due')
      order.payment_state = 'paid'
      expect(order.state_changes).to be_empty
      Spree::Deprecation.silence do
        order.state_changed('payment')
      end
      state_change = order.state_changes.find_by(name: 'payment')
      expect(state_change.previous_state).to eq('balance_due')
      expect(state_change.next_state).to eq('paid')
    end

    it "does not do anything if state does not change" do
      order.update_column(:payment_state, 'balance_due')
      expect(order.state_changes).to be_empty
      Spree::Deprecation.silence do
        order.state_changed('payment')
      end
      expect(order.state_changes).to be_empty
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

  context "#apply_shipping_promotions" do
    it "calls out to the Shipping promotion handler" do
      expect_any_instance_of(Spree::PromotionHandler::Shipping).to(
        receive(:activate)
      ).and_call_original

      expect(order.updater).to receive(:update).and_call_original

      order.apply_shipping_promotions
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

    context "passing options" do
      it 'is deprecated' do
        expect(Spree::Deprecation).to receive(:warn)
        order.generate_order_number(length: 2)
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
        let(:bill_address) { build(:address, firstname: nil) } # invalid address

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
        let(:ship_address) { build(:address, firstname: nil) } # invalid address

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

  describe "#item_total_excluding_vat" do
    it "sums all of the line items' pre tax amounts" do
      subject.line_items = [
        Spree::LineItem.new(price: 10, quantity: 2, included_tax_total: 15.0),
        Spree::LineItem.new(price: 30, quantity: 1, included_tax_total: 16.0)
      ]
      # (2*10)-15 + 30-16 = 5 + 14 = 19
      expect(subject.item_total_excluding_vat).to eq 19.0
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
      let(:payment) { order.payments.first.tap { |p| allow(p).to receive_messages(profiles_supported?: false) } }
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

      context 'there is store credit in another currency' do
        let(:order) { create(:order_with_totals, user: user, line_items_price: order_total).tap(&:recalculate) }
        let!(:store_credit_usd) { create(:store_credit, user: user, amount: 1, currency: 'USD') }
        let!(:store_credit_gbp) { create(:store_credit, user: user, amount: 1, currency: 'GBP') }
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
            cc_payment = create(:payment, order: order)
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
          let!(:cc_payment) { create(:payment, order: order, state: "completed", amount: 100) }

          it "successfully creates the store credit payments" do
            expect { subject }.to change { order.payments.count }.from(1).to(2)
            expect(order.errors).to be_empty
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

      let(:order) { create(:order_with_line_items, user: user, store: store) }

      context "order doesn't have an associated user" do
        let(:user) { nil }
        it { is_expected.to eq(false) }
      end

      context "order has an associated user" do
        context "user has enough store credit to pay for the order" do
          let!(:credit) { create(:store_credit, user: user, amount: 1000) }
          it { is_expected.to eq(true) }
        end

        context "user does not have enough store credit to pay for the order" do
          let!(:credit) { create(:store_credit, user: user, amount: 1) }
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
        let!(:credit) { create(:store_credit, user: user, amount: 25) }
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

      before { allow(subject).to receive_messages(total_applicable_store_credit: total_applicable_store_credit) }

      it "returns a money instance" do
        expect(subject.display_total_applicable_store_credit).to be_a(Spree::Money)
      end

      it "returns a negative amount" do
        expect(subject.display_total_applicable_store_credit.money.cents).to eq(total_applicable_store_credit * -100.0)
      end
    end

    describe "#record_ip_address" do
      let(:ip_address) { "127.0.0.1" }

      subject { -> { order.record_ip_address(ip_address) } }

      it "updates the last used IP address" do
        expect(subject).to change(order, :last_ip_address).to(ip_address)
      end

      # IP address tracking should not raise validation exceptions
      context "with an invalid order" do
        before { allow(order).to receive(:valid?).and_return(false) }

        it "updates the IP address" do
          expect(subject).to change(order, :last_ip_address).to(ip_address)
        end
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

  context 'update_params_payment_source' do
    subject { described_class.new }

    it 'is deprecated' do
      subject.instance_variable_set('@updating_params', {})
      expect(Spree::Deprecation).to receive(:warn)
      subject.send(:update_params_payment_source)
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
end

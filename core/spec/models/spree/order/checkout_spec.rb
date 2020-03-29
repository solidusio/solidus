# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/order_walkthrough'

RSpec.describe Spree::Order, type: :model do
  let!(:store) { create(:store) }
  let(:order) { Spree::Order.new(store: store) }

  def assert_state_changed(order, from, to)
    state_change_exists = order.state_changes.where(previous_state: from, next_state: to).exists?
    expect(state_change_exists).to be(true), "Expected order to transition from #{from} to #{to}, but didn't."
  end

  context "with default state machine" do
    transitions = [
      { address: :delivery },
      { delivery: :payment },
      { payment: :confirm },
      { delivery: :confirm }
    ]

    transitions.each do |transition|
      it "transitions from #{transition.keys.first} to #{transition.values.first}" do
        transition = Spree::Order.find_transition(from: transition.keys.first, to: transition.values.first)
        expect(transition).not_to be_nil
      end
    end

    it '.find_transition when contract was broken' do
      expect(Spree::Order.find_transition({ foo: :bar, baz: :dog })).to be_falsey
    end

    describe "remove_transition" do
      after do
        Spree::Order.checkout_flow(&@old_checkout_flow)
      end

      it '.remove_transition', partial_double_verification: false do
        options = { from: transitions.first.keys.first, to: transitions.first.values.first }
        allow(Spree::Order).to receive(:next_event_transition).and_return([options])
        expect(Spree::Order.remove_transition(options)).to be_truthy
      end

      it '.remove_transition when contract was broken' do
        expect(Spree::Order.remove_transition(nil)).to be_falsey
      end
    end

    it "always return integer on checkout_step_index" do
      expect(order.checkout_step_index("imnotthere")).to be_a Integer
      expect(order.checkout_step_index("delivery")).to be > 0
    end

    it "passes delivery state when transitioning from address over delivery to payment" do
      allow(order).to receive_messages payment_required?: true
      order.state = "address"
      expect(order.passed_checkout_step?("delivery")).to be false
      order.state = "delivery"
      expect(order.passed_checkout_step?("delivery")).to be false
      order.state = "payment"
      expect(order.passed_checkout_step?("delivery")).to be true
    end

    context "#checkout_steps" do
      context "when confirmation not required" do
        before do
          allow(order).to receive_messages payment_required?: true
        end

        specify do
          expect(order.checkout_steps).to eq(%w(address delivery payment confirm complete))
        end
      end

      context "when confirmation required" do
        before do
          allow(order).to receive_messages payment_required?: true
        end

        specify do
          expect(order.checkout_steps).to eq(%w(address delivery payment confirm complete))
        end
      end

      context "when payment not required" do
        before { allow(order).to receive_messages payment_required?: false }
        specify do
          expect(order.checkout_steps).to eq(%w(address delivery confirm complete))
        end
      end

      context "when payment required" do
        before { allow(order).to receive_messages payment_required?: true }
        specify do
          expect(order.checkout_steps).to eq(%w(address delivery payment confirm complete))
        end
      end
    end

    it "starts out at cart" do
      expect(order.state).to eq("cart")
    end

    context "to address" do
      before do
        order.email = "user@example.com"
        order.save!
      end

      context "with a line item" do
        before do
          order.line_items << FactoryBot.create(:line_item)
        end

        it "transitions to address" do
          order.next!
          assert_state_changed(order, 'cart', 'address')
          expect(order.state).to eq("address")
        end

        it "doesn't raise an error if the default address is invalid" do
          order.user = mock_model(Spree::LegacyUser, ship_address: Spree::Address.new, bill_address: Spree::Address.new)
          order.next!
        end

        context "with default addresses" do
          let(:default_address) { FactoryBot.create(:address) }

          shared_examples "it references the user's the default address" do
            it do
              default_attributes = default_address.reload.value_attributes
              order_attributes = Spree::Address.value_attributes(order.send("#{address_kind}_address".to_sym).try(:attributes))

              expect(order_attributes).to eq(default_attributes)
            end
          end

          it_behaves_like "it references the user's the default address" do
            let(:address_kind) { :ship }
            before do
              order.user = FactoryBot.create(:user)
              order.user.ship_address = default_address
              order.next!
              order.reload
            end
          end

          it_behaves_like "it references the user's the default address" do
            let(:address_kind) { :bill }
            before do
              order.user = FactoryBot.create(:user)
              order.user.bill_address = default_address
              order.next!
              order.reload
            end
          end
        end
      end

      it "cannot transition to address without any line items" do
        expect(order.line_items).to be_blank
        expect { order.next! }.to raise_error(StateMachines::InvalidTransition, /#{I18n.t('spree.there_are_no_items_for_this_order')}/)
      end
    end

    context "from address" do
      let(:ship_address) { create(:ship_address) }
      let!(:line_item) { create(:line_item, order: order, price: 10) }
      let!(:shipping_method) { create(:shipping_method) }

      before do
        order.line_items.reload
        order.state = 'address'
        order.ship_address = ship_address
        order.email = "user@example.com"
        order.save!
      end

      context "no shipping address" do
        let(:ship_address) { nil }

        it "does not transition without a ship address" do
          expect { order.next! }.to raise_error StateMachines::InvalidTransition
        end
      end

      it "recalculates tax and updates totals" do
        zone = create(:zone, countries: [order.tax_address.country])
        create(:tax_rate, tax_categories: [line_item.tax_category], amount: 0.05, zone: zone)
        order.next!
        expect(order).to have_attributes(
          adjustment_total: 0.5,
          additional_tax_total: 0.5,
          included_tax_total: 0,
          total: 20.5
        )
      end

      it "transitions to delivery" do
        order.next!
        assert_state_changed(order, 'address', 'delivery')
        expect(order.state).to eq("delivery")
      end

      it "does not call persist_order_address if there is no address on the order" do
        order.user = FactoryBot.create(:user)
        order.save!

        expect(order.user).to_not receive(:persist_order_address).with(order)
        order.next!
      end

      it "calls persist_order_address on the order's user" do
        order.user = FactoryBot.create(:user)
        order.ship_address = FactoryBot.create(:address)
        order.bill_address = FactoryBot.create(:address)
        order.save!

        expect(order.user).to receive(:persist_order_address).with(order)
        order.next!
      end

      it "does not call persist_order_address on the order's user for a temporary address" do
        order.user = FactoryBot.create(:user)
        order.temporary_address = true
        order.save!

        expect(order.user).to_not receive(:persist_order_address)
        order.next!
      end
    end

    context "to delivery" do
      let(:ship_address) { FactoryBot.create(:ship_address) }

      before do
        order.ship_address = ship_address
      end

      context 'when order has default selected_shipping_rate_id', partial_double_verification: false do
        let(:shipment) { create(:shipment, order: order) }
        let(:shipping_method) { create(:shipping_method) }
        let(:shipping_rate) {
          [
          Spree::ShippingRate.create!(shipping_method: shipping_method, cost: 10.00, shipment: shipment)
        ]
        }

        before do
          order.state = 'address'
          shipment.selected_shipping_rate_id = shipping_rate.first.id
          order.email = "user@example.com"
          order.save!

          allow(order).to receive(:create_proposed_shipments)
          allow(order).to receive(:ensure_available_shipping_rates) { true }
        end

        it 'should update shipment_total' do
          expect { order.next! }.to change{ order.shipment_total }.by(10.00)
        end
      end

      context "cannot transition to delivery" do
        context "if there are no shipping rates for any shipment" do
          let!(:line_item){ create :line_item, order: order }
          before do
            order.state = 'address'
            order.email = 'user@example.com'
          end
          specify do
            transition = lambda { order.next! }
            expect(transition).to raise_error(StateMachines::InvalidTransition, /#{I18n.t('spree.items_cannot_be_shipped')}/)
          end
        end
      end
    end

    context "from delivery", partial_double_verification: false do
      let(:ship_address) { FactoryBot.create(:ship_address) }

      before do
        order.ship_address = ship_address
        order.state = 'delivery'
        allow(order).to receive(:apply_shipping_promotions)
        allow(order).to receive(:ensure_available_shipping_rates) { true }
      end

      it "attempts to apply free shipping promotions" do
        expect(order).to receive(:apply_shipping_promotions)
        order.next!
      end

      context "with payment required" do
        before do
          allow(order).to receive_messages payment_required?: true
        end

        it "transitions to payment" do
          order.next!
          assert_state_changed(order, 'delivery', 'payment')
          expect(order.state).to eq('payment')
        end
      end

      context "without payment required" do
        before do
          allow(order).to receive_messages payment_required?: false
        end

        it "transitions to complete" do
          order.next!
          expect(order.state).to eq("confirm")
        end
      end

      context "correctly determining payment required based on shipping information" do
        let(:shipment) do
          FactoryBot.create(:shipment)
        end

        before do
          # Needs to be set here because we're working with a persisted order object
          order.email = "test@example.com"
          order.save!
          order.shipments << shipment
        end

        context "with a shipment that has a price" do
          before do
            shipment.shipping_rates.first.update_column(:cost, 10)
            order.recalculate
          end

          it "transitions to payment" do
            order.next!
            expect(order.state).to eq("payment")
          end
        end

        context "with a shipment that is free" do
          before do
            shipment.shipping_rates.first.update_column(:cost, 0)
          end

          it "skips payment, transitions to confirm" do
            order.next!
            expect(order.state).to eq("confirm")
          end
        end
      end
    end

    context "to payment" do
      let(:user_bill_address)   { nil }
      let(:order_bill_address)  { nil }
      let(:default_credit_card) { create(:credit_card) }

      before do
        user = create(:user, email: 'spree@example.org', bill_address: user_bill_address)
        default_credit_card.update(user: user)
        wallet_payment_source = user.wallet.add(default_credit_card)
        user.wallet.default_wallet_payment_source = wallet_payment_source
        order.user = user

        allow(order).to receive_messages(payment_required?: true)
        order.state = 'delivery'
        order.bill_address = order_bill_address
        order.save!
        order.next!
        order.reload
      end

      it "assigns the user's default credit card" do
        expect(order.state).to eq 'payment'
        expect(order.payments.count).to eq 1
        expect(order.payments.first.source).to eq default_credit_card
      end

      context "order already has a billing address" do
        let(:order_bill_address) { create(:address) }

        it "keeps the order's billing address" do
          expect(order.bill_address).to eq order_bill_address
        end
      end

      context "order doesn't have a billing address" do
        it "assigns the user's default_credit_card's address to the order" do
          expect(order.bill_address).to eq default_credit_card.address
        end
      end
    end

    context "from payment" do
      before do
        order.state = 'payment'
        allow(order).to receive(:ensure_available_shipping_rates) { true }
      end

      context "with confirmation required" do
        before do
        end

        it "transitions to confirm" do
          order.next!
          assert_state_changed(order, 'payment', 'confirm')
          expect(order.state).to eq("confirm")
        end
      end

      # Regression test for https://github.com/spree/spree/issues/2028
      context "when payment is not required" do
        before do
          allow(order).to receive_messages payment_required?: false
        end

        it "does not call process payments" do
          expect(order).not_to receive(:process_payments!)
          order.next!
          assert_state_changed(order, 'payment', 'confirm')
          expect(order.state).to eq("confirm")
        end
      end
    end
  end

  context "from confirm" do
    before do
      order.state = 'confirm'
      order.save!
    end

    it "returns false on next" do
      expect(order.next).to be_falsy
    end

    it "is unable to next" do
      expect(order).not_to be_can_next
    end
  end

  context "to complete" do
    before do
      order.state = 'confirm'
      order.save!
    end

    context "out of stock" do
      before do
        order.user = FactoryBot.create(:user)
        order.email = 'spree@example.org'
        order.payments << FactoryBot.create(:payment)
        allow(order).to receive_messages(payment_required?: true)
        order.line_items << FactoryBot.create(:line_item)
        order.line_items.first.variant.stock_items.each do |si|
          si.set_count_on_hand(0)
          si.update(backorderable: false)
        end

        Spree::OrderUpdater.new(order).update
        order.save!
      end

      it "does not allow the order to complete" do
        expect {
          order.complete!
        }.to raise_error Spree::Order::InsufficientStock

        expect(order.state).to eq 'confirm'
        expect(order.line_items.first.errors[:quantity]).to be_present
        expect(order.payments.first.state).to eq('checkout')
      end
    end

    context "no inventory units" do
      before do
        order.user = FactoryBot.create(:user)
        order.email = 'spree@example.com'
        order.payments << FactoryBot.create(:payment)
        allow(order).to receive_messages(payment_required?: true)
        allow(order).to receive(:ensure_available_shipping_rates) { true }
        order.line_items << FactoryBot.create(:line_item)

        Spree::OrderUpdater.new(order).update
        order.save!
      end

      it "does not allow order to complete" do
        expect { order.complete! }.to raise_error Spree::Order::InsufficientStock

        expect(order.state).to eq 'confirm'
        expect(order.line_items.first.errors[:inventory]).to be_present
        expect(order.payments.first.state).to eq('checkout')
      end
    end

    context "with a payment in the pending state" do
      let(:order) { create :order_ready_to_complete }
      let(:payment) { create :payment, order: order, state: "pending", amount: order.total }

      it "allows the order to complete" do
        expect { order.complete! }.
          to change { order.state }.
          from("confirm").
          to("complete")
      end
    end

    context "exchange order completion" do
      before do
        order.email = 'spree@example.org'
        order.payments << FactoryBot.create(:payment)
        order.shipments.create!
        allow(order).to receive_messages(payment_required?: true)
        allow(order).to receive(:ensure_available_shipping_rates).and_return(true)
      end

      context 'when the line items are not available' do
        before do
          order.line_items << FactoryBot.create(:line_item)
          order.store = FactoryBot.build(:store)
          Spree::OrderUpdater.new(order).update

          order.save!
        end

        it 'does not allow the order to completed' do
          expect { order.complete! }.to raise_error Spree::Order::InsufficientStock
          expect(order.payments.first.state).to eq('checkout')
        end
      end
    end

    context "default credit card", partial_double_verification: false do
      before do
        order.user = FactoryBot.create(:user)
        order.store = FactoryBot.create(:store)
        order.email = 'spree@example.org'
        order.payments << FactoryBot.create(:payment, order: order)

        # make sure we will actually capture a payment
        allow(order).to receive_messages(payment_required?: true)
        allow(order).to receive_messages(ensure_available_shipping_rates: true)
        allow(order).to receive_messages(validate_line_item_availability: true)
        order.line_items << FactoryBot.create(:line_item)
        order.create_proposed_shipments
        Spree::OrderUpdater.new(order).update

        order.save!
      end

      it "makes the current credit card a user's default credit card" do
        order.complete!
        expect(order.state).to eq 'complete'
        expect(order.user.reload.wallet.default_wallet_payment_source.payment_source).to eq(order.credit_cards.first)
      end

      it "does not assign a default credit card if temporary_payment_source is set" do
        order.temporary_payment_source = true
        order.complete!
        expect(order.user.reload.wallet.default_wallet_payment_source).to be_nil
      end
    end

    context "a payment fails during processing", partial_double_verification: false do
      before do
        order.user = FactoryBot.create(:user)
        order.email = 'spree@example.org'
        payment = FactoryBot.create(:payment)
        allow(payment).to receive(:process!).and_raise(Spree::Core::GatewayError.new('processing failed'))
        order.line_items.each { |li| li.inventory_units.create! }
        order.payments << payment

        # make sure we will actually capture a payment
        allow(order).to receive_messages(payment_required?: true)
        allow(order).to receive_messages(ensure_available_shipping_rates: true)
        allow(order).to receive_messages(validate_line_item_availability: true)
        order.line_items << FactoryBot.create(:line_item)
        order.create_proposed_shipments
        Spree::OrderUpdater.new(order).update
      end

      it "transitions to the payment state" do
        expect { order.complete! }.to raise_error StateMachines::InvalidTransition
        expect(order.reload.state).to eq 'payment'
      end
    end

    context 'the order is already paid' do
      let(:order) { create(:order_with_line_items) }

      it 'can complete the order' do
        create(:payment, state: 'completed', order: order, amount: order.total)
        order.recalculate
        expect(order.complete).to eq(true)
      end
    end
  end

  context "re-define checkout flow" do
    before do
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        checkout_flow do
          go_to_state :payment
          go_to_state :complete
        end
      end
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "should not keep old event transitions when checkout_flow is redefined" do
      expect(Spree::Order.next_event_transitions).to eq([{ cart: :payment }, { payment: :complete }])
    end

    it "should not keep old events when checkout_flow is redefined" do
      state_machine = Spree::Order.state_machine
      expect(state_machine.states.any? { |s| s.name == :address }).to be false
      known_states = state_machine.events[:next].branches.flat_map(&:known_states)
      expect(known_states).not_to include(:address)
      expect(known_states).not_to include(:delivery)
      expect(known_states).not_to include(:confirm)
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3665
  context "with only a complete step" do
    let!(:line_item){ create :line_item, order: order }

    before do
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        checkout_flow do
          go_to_state :complete
        end
      end
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "does not attempt to check shipping rates" do
      order.email = 'user@example.com'
      expect(order).not_to receive(:ensure_available_shipping_rates)
      order.next!
      assert_state_changed(order, 'cart', 'complete')
    end

    it "does not attempt to process payments", partial_double_verification: false do
      order.email = 'user@example.com'
      allow(order).to receive(:ensure_promotions_eligible).and_return(true)
      allow(order).to receive(:ensure_line_item_variants_are_not_deleted).and_return(true)
      allow(order).to receive_message_chain(:line_items, :present?).and_return(true)
      allow(order).to receive_messages(validate_line_item_availability: true)
      expect(order).not_to receive(:payment_required?)
      expect(order).not_to receive(:process_payments!)
      order.next!
      assert_state_changed(order, 'cart', 'complete')
    end
  end

  context "insert checkout step" do
    before do
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        remove_transition from: :delivery, to: :confirm
      end
      Spree::Order.class_eval do
        insert_checkout_step :new_step, before: :address
      end
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "should maintain removed transitions" do
      transition = Spree::Order.find_transition(from: :delivery, to: :confirm)
      expect(transition).to be_nil
    end

    context "before" do
      before do
        Spree::Order.class_eval do
          insert_checkout_step :before_address, before: :address
        end
      end

      specify do
        order = Spree::Order.new
        expect(order.checkout_steps).to eq(%w(new_step before_address address delivery confirm complete))
      end
    end

    context "after" do
      before do
        Spree::Order.class_eval do
          insert_checkout_step :after_address, after: :address
        end
      end

      specify do
        order = Spree::Order.new
        expect(order.checkout_steps).to eq(%w(new_step address after_address delivery confirm complete))
      end
    end
  end

  context "remove checkout step" do
    before do
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        remove_transition from: :delivery, to: :confirm
      end
      Spree::Order.class_eval do
        remove_checkout_step :address
      end
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "should maintain removed transitions" do
      transition = Spree::Order.find_transition(from: :delivery, to: :confirm)
      expect(transition).to be_nil
    end

    specify do
      order = Spree::Order.new
      expect(order.checkout_steps).to eq(%w(delivery confirm complete))
    end
  end
end

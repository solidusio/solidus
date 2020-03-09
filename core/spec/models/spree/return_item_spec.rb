# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ReturnItem, type: :model do
  all_reception_statuses = Spree::ReturnItem.state_machines[:reception_status].states.map(&:name).map(&:to_s)
  all_acceptance_statuses = Spree::ReturnItem.state_machines[:acceptance_status].states.map(&:name).map(&:to_s)

  shared_examples "an invalid state transition" do |status, expected_status|
    let(:status) { status }

    it "cannot transition to #{expected_status}" do
      expect { subject }.to raise_error(StateMachines::InvalidTransition)
    end
  end

  before do
    allow_any_instance_of(Spree::Order).to receive(:return!).and_return(true)
  end

  describe '#receive!' do
    let(:now)            { Time.current }
    let(:order)          { create(:shipped_order) }
    let(:inventory_unit) { create(:inventory_unit, state: 'shipped') }
    let!(:customer_return) { create(:customer_return_without_return_items, return_items: [return_item], stock_location_id: inventory_unit.shipment.stock_location_id) }
    let(:return_item) { create(:return_item, inventory_unit: inventory_unit) }

    before do
      inventory_unit.update!(state: 'shipped')
      return_item.update!(reception_status: 'awaiting')
      allow(return_item).to receive(:eligible_for_return?).and_return(true)
    end

    subject { return_item.receive! }

    it 'returns the inventory unit' do
      subject
      expect(inventory_unit.reload.state).to eq 'returned'
    end

    it 'attempts to accept the return item' do
      expect(return_item).to receive(:attempt_accept)
      subject
    end

    context 'when the `skip_customer_return_processing` flag is set' do
      before { Spree::Deprecation.silence { return_item.skip_customer_return_processing = false } }

      it 'shows a deprecation warning' do
        expect(Spree::Deprecation).to receive(:warn)
        subject
      end
    end

    context 'when there is a received return item with the same inventory unit' do
      let!(:return_item_with_dupe_inventory_unit) { create(:return_item, inventory_unit: inventory_unit, reception_status: 'received') }

      before do
        expect { subject }.to raise_error { StateMachines::InvalidTransition }
      end

      it 'does not receive the return item' do
        expect(return_item.reception_status).to eq 'awaiting'
      end

      it 'adds an error to the return item' do
        expect(return_item.errors[:inventory_unit]).to include "#{return_item.inventory_unit_id} has already been taken by return item #{return_item_with_dupe_inventory_unit.id}"
      end
    end

    context 'when the received item is actually the exchange (aka customer changed mind about exchange)' do
      let(:exchange_inventory_unit) { create(:inventory_unit, state: 'shipped') }
      let!(:return_item_with_exchange) { create(:return_item, inventory_unit: inventory_unit, exchange_inventory_unit: exchange_inventory_unit) }
      let!(:return_item_in_lieu) { create(:return_item, inventory_unit: exchange_inventory_unit) }

      it 'unexchanges original return item' do
        return_item_in_lieu.receive!

        return_item_with_exchange.reload
        return_item_in_lieu.reload
        expect(return_item_with_exchange.reception_status).to eq 'unexchanged'
        expect(return_item_in_lieu.reception_status).to eq 'received'
        expect(return_item_in_lieu.amount).to eq 0
        expect(inventory_unit.reload.state).to eq 'shipped'
        expect(exchange_inventory_unit.reload.state).to eq 'returned'
      end
    end

    context 'with a stock location' do
      let(:stock_location) { customer_return.stock_location }
      let(:stock_item) { stock_location.stock_item(inventory_unit.variant) }

      before do
        inventory_unit.update!(state: 'shipped')
        return_item.update!(reception_status: 'awaiting')
        stock_location.update!(restock_inventory: true)
      end

      it 'increases the count on hand' do
        expect { subject }.to change { stock_item.reload.count_on_hand }.by(1)
      end

      context 'when variant does not track inventory' do
        before do
          inventory_unit.update!(state: 'shipped')
          inventory_unit.variant.update!(track_inventory: false)
          return_item.update!(reception_status: 'awaiting')
        end

        it 'does not increase the count on hand' do
          expect { subject }.to_not change { stock_item.reload.count_on_hand }
        end
      end

      context "when the stock location's restock_inventory is false" do
        before do
          stock_location.update!(restock_inventory: false)
        end

        it 'does not increase the count on hand' do
          expect { subject }.to_not change { stock_item.reload.count_on_hand }
        end
      end

      context "when the inventory unit's variant does not yet have a stock item for the stock location it was returned to" do
        before { inventory_unit.variant.stock_items.each(&:really_destroy!) }

        it "creates a new stock item for the inventory unit with a count of 1" do
          expect { subject }.to change(Spree::StockItem, :count).by(1)
          stock_item = Spree::StockItem.last
          expect(stock_item.variant).to eq inventory_unit.variant
          expect(stock_item.count_on_hand).to eq 1
        end
      end

      Spree::ReturnItem::INTERMEDIATE_RECEPTION_STATUSES.each do |status|
        context "when the item was #{status}" do
          before { return_item.update!(reception_status: status) }

          it 'processes the inventory unit' do
            subject
            expect(return_item.inventory_unit.reload.state).to eq('returned')
          end

          it 'return remains accepted' do
            subject
            expect(return_item.acceptance_status).to eq('accepted')
          end
        end
      end
    end
  end

  describe "#display_total_excluding_vat" do
    let(:amount) { 21.22 }
    let(:included_tax_total) { 1.22 }
    let(:return_item) { build(:return_item, amount: amount, included_tax_total: included_tax_total) }

    it "returns a Spree::Money" do
      expect(return_item.display_total_excluding_vat).to eq Spree::Money.new(amount - included_tax_total)
    end
  end

  describe ".default_refund_amount_calculator" do
    it "defaults to the default refund amount calculator" do
      expect(Spree::ReturnItem.refund_amount_calculator).to eq Spree::Calculator::Returns::DefaultRefundAmount
    end
  end

  describe "amount calculations on create" do
    let(:inventory_unit) { build(:inventory_unit) }
    before { subject.save! }

    context "amount is not specified" do
      subject { build(:return_item, inventory_unit: inventory_unit) }

      context "not an exchange" do
        it { expect(subject.amount).to eq Spree::Calculator::Returns::DefaultRefundAmount.new.compute(subject) }
      end

      context "an exchange" do
        subject { build(:exchange_return_item) }

        it { expect(subject.amount).to eq 0.0 }
      end
    end

    context "amount is specified" do
      subject { build(:return_item, inventory_unit: inventory_unit, amount: 100) }

      it { expect(subject.amount).to eq 100 }
    end
  end

  describe ".from_inventory_unit" do
    let(:inventory_unit) { build(:inventory_unit) }

    subject { Spree::ReturnItem.from_inventory_unit(inventory_unit) }

    context "with a cancelled return item" do
      let!(:return_item) { create(:return_item, inventory_unit: inventory_unit, reception_status: 'cancelled') }

      it { is_expected.not_to be_persisted }
    end

    context 'with a expired item' do
      let!(:return_item) { create(:return_item, inventory_unit: inventory_unit, reception_status: 'expired') }

      it { is_expected.not_to be_persisted }
    end

    context "with a non-cancelled return item" do
      let!(:return_item) { create(:return_item, inventory_unit: inventory_unit) }

      it { is_expected.to be_persisted }
    end
  end

  describe "reception_status state_machine" do
    subject(:return_item) { create(:return_item) }

    it "starts off in the awaiting state" do
      expect(return_item).to be_awaiting
    end

    context 'when transitioning to :received' do
      let(:return_item) { create(:return_item) }
      subject { return_item.receive! }

      # StateMachines has some "smart" code for guessing how many arguments to
      # send to the callback methods that interferes with rspec-mocks.
      around { |e| without_partial_double_verification { e.call } }

      it 'calls #attempt_accept, #check_unexchange, and #process_inventory_unit!' do
        expect(return_item).to receive(:attempt_accept)
        expect(return_item).to receive(:check_unexchange)
        expect(return_item).to receive(:process_inventory_unit!)

        subject
      end

      context 'when the :acceptance_status is in a state that does not support the :attempt_accept event' do
        before { return_item.require_manual_intervention! }

        it 'only skips the call to :attempt_accept' do
          expect(return_item).not_to receive(:attempt_accept)
          expect(return_item).to receive(:check_unexchange)
          expect(return_item).to receive(:process_inventory_unit!)

          subject
        end
      end
    end
  end

  describe "acceptance_status state_machine" do
    subject(:return_item) { create(:return_item) }

    it "starts off in the pending state" do
      expect(return_item).to be_pending
    end
  end

  describe "#receive" do
    let(:order) { create(:shipped_order) }
    let(:inventory_unit) { create(:inventory_unit, shipment: order.shipments.first) }
    let(:return_item)    { create(:return_item, reception_status: status, inventory_unit: inventory_unit) }

    subject { return_item.receive! }

    context "awaiting status" do
      let(:status) { 'awaiting' }

      before do
        expect(return_item.inventory_unit).to receive(:return!)
      end

      before { subject }

      it "transitions successfully" do
        expect(return_item).to be_received
      end
    end

    context "return_item has a reception status of cancelled" do
      it_behaves_like "an invalid state transition", 'cancelled', 'received'
    end
  end

  describe "#cancel" do
    let(:return_item) { create(:return_item, reception_status: status) }

    subject { return_item.cancel! }

    context "awaiting status" do
      let(:status) { 'awaiting' }

      before { subject }

      it "transitions successfully" do
        expect(return_item).to be_cancelled
      end
    end

    (all_reception_statuses - ['awaiting']).each do |invalid_transition_status|
      context "return_item has a reception status of #{invalid_transition_status}" do
        it_behaves_like "an invalid state transition", invalid_transition_status, 'cancelled'
      end
    end
  end

  {
    give: 'given_to_customer',
    lost: 'lost_in_transit',
    wrong_item_shipped: 'shipped_wrong_item',
    in_transit: 'in_transit',
    short_shipped: 'short_shipped'
  }.each do |transition, status|
    describe "##{transition}" do
      let(:return_item) { create(:return_item, reception_status: status, inventory_unit: inventory_unit) }
      let(:inventory_unit) { create(:inventory_unit, state: 'shipped') }
      subject { return_item.public_send("#{transition}!") }
      context "awaiting status" do
        before do
          return_item.update!(reception_status: 'awaiting')
          allow(return_item).to receive(:eligible_for_return?).and_return(true)
        end

        it 'accepts the return' do
          subject
          expect(return_item.acceptance_status).to eq('accepted')
        end

        it 'does not decrease inventory' do
          expect(return_item).to_not receive(:process_inventory_unit!)
          subject
        end

        it "transitions successfully" do
          subject
          expect(return_item.reception_status).to eq status
        end
      end

      it_behaves_like "an invalid state transition", 'cancelled', status
    end
  end

  describe "#attempt_accept" do
    let(:return_item) { create(:return_item, acceptance_status: status) }
    let(:validator_errors) { {} }
    let(:validator_double) { double(errors: validator_errors) }

    subject { return_item.attempt_accept! }

    before do
      allow(return_item).to receive(:validator).and_return(validator_double)
    end

    context "pending status" do
      let(:status) { 'pending' }

      before do
        allow(return_item).to receive(:eligible_for_return?).and_return(true)
        subject
      end

      it "transitions successfully" do
        expect(return_item).to be_accepted
      end

      it "has no acceptance status errors" do
        expect(return_item.acceptance_status_errors).to be_empty
      end
    end

    (all_acceptance_statuses - ['accepted', 'pending']).each do |invalid_transition_status|
      context "return_item has an acceptance status of #{invalid_transition_status}" do
        it_behaves_like "an invalid state transition", invalid_transition_status, 'accepted'
      end
    end

    context "not eligible for return" do
      let(:status) { 'pending' }
      let(:validator_errors) { { number_of_days: "Return Item is outside the eligible time period" } }

      before do
        allow(return_item).to receive(:eligible_for_return?).and_return(false)
      end

      context "manual intervention required" do
        before do
          allow(return_item).to receive(:requires_manual_intervention?).and_return(true)
          subject
        end

        it "transitions to manual intervention required" do
          expect(return_item).to be_manual_intervention_required
        end

        it "sets the acceptance status errors" do
          expect(return_item.acceptance_status_errors).to eq validator_errors
        end
      end

      context "manual intervention not required" do
        before do
          allow(return_item).to receive(:requires_manual_intervention?).and_return(false)
          subject
        end

        it "transitions to rejected" do
          expect(return_item).to be_rejected
        end

        it "sets the acceptance status errors" do
          expect(return_item.acceptance_status_errors).to eq validator_errors
        end
      end
    end
  end

  describe "#reject" do
    let(:return_item) { create(:return_item, acceptance_status: status) }

    subject { return_item.reject! }

    context "pending status" do
      let(:status) { 'pending' }

      before { subject }

      it "transitions successfully" do
        expect(return_item).to be_rejected
      end

      it "has no acceptance status errors" do
        expect(return_item.acceptance_status_errors).to be_empty
      end
    end

    (all_acceptance_statuses - ['accepted', 'pending', 'manual_intervention_required']).each do |invalid_transition_status|
      context "return_item has an acceptance status of #{invalid_transition_status}" do
        it_behaves_like "an invalid state transition", invalid_transition_status, 'rejected'
      end
    end
  end

  describe "#accept" do
    let(:return_item) { create(:return_item, acceptance_status: status) }

    subject { return_item.accept! }

    context "pending status" do
      let(:status) { 'pending' }

      before { subject }

      it "transitions successfully" do
        expect(return_item).to be_accepted
      end

      it "has no acceptance status errors" do
        expect(return_item.acceptance_status_errors).to be_empty
      end
    end

    (all_acceptance_statuses - ['accepted', 'pending', 'manual_intervention_required']).each do |invalid_transition_status|
      context "return_item has an acceptance status of #{invalid_transition_status}" do
        it_behaves_like "an invalid state transition", invalid_transition_status, 'accepted'
      end
    end
  end

  describe "#require_manual_intervention" do
    let(:return_item) { create(:return_item, acceptance_status: status) }

    subject { return_item.require_manual_intervention! }

    context "pending status" do
      let(:status) { 'pending' }

      before { subject }

      it "transitions successfully" do
        expect(return_item).to be_manual_intervention_required
      end

      it "has no acceptance status errors" do
        expect(return_item.acceptance_status_errors).to be_empty
      end
    end

    (all_acceptance_statuses - ['accepted', 'pending', 'manual_intervention_required']).each do |invalid_transition_status|
      context "return_item has an acceptance status of #{invalid_transition_status}" do
        it_behaves_like "an invalid state transition", invalid_transition_status, 'manual_intervention_required'
      end
    end
  end

  describe 'validity for reimbursements' do
    let(:return_item) { create(:return_item, acceptance_status: acceptance_status) }
    let(:acceptance_status) { 'pending' }

    before { return_item.reimbursement = build(:reimbursement) }

    subject { return_item }

    context 'when acceptance_status is accepted' do
      let(:acceptance_status) { 'accepted' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when acceptance_status is accepted' do
      let(:acceptance_status) { 'pending' }

      it 'is valid' do
        expect(subject).to_not be_valid
        expect(subject.errors.messages).to eq({ reimbursement: [I18n.t(:cannot_be_associated_unless_accepted, scope: 'activerecord.errors.models.spree/return_item.attributes.reimbursement')] })
      end
    end
  end

  describe "#part_of_exchange?" do
    context "exchange variant exists, unexchanged sibling does not" do
      before { allow(subject).to receive(:exchange_variant).and_return(mock_model(Spree::Variant)) }
      it { expect(subject.part_of_exchange?).to eq true }
    end
    context "exchange variant does not exist, but unexchagned sibling does" do
      before { expect(subject).to receive(:sibling_intended_for_exchange).with('unexchanged').and_return(true) }
      it { expect(subject.part_of_exchange?).to eq true }
    end
    context "neither exchange variant nor unexchanged sibling exist" do
      before { expect(subject).to receive(:sibling_intended_for_exchange).with('unexchanged').and_return(false) }
      it { expect(subject.part_of_exchange?).to eq false }
    end
  end

  describe "#exchange_requested?" do
    context "exchange variant exists" do
      before { allow(subject).to receive(:exchange_variant).and_return(mock_model(Spree::Variant)) }
      it { expect(subject.exchange_requested?).to eq true }
    end
    context "exchange variant does not exist" do
      before { allow(subject).to receive(:exchange_variant).and_return(nil) }
      it { expect(subject.exchange_requested?).to eq false }
    end
  end

  describe "#exchange_processed?" do
    context "exchange inventory unit exists" do
      before { allow(subject).to receive(:exchange_inventory_unit).and_return(mock_model(Spree::InventoryUnit)) }
      it { expect(subject.exchange_processed?).to eq true }
    end
    context "exchange inventory unit does not exist" do
      before { allow(subject).to receive(:exchange_inventory_unit).and_return(nil) }
      it { expect(subject.exchange_processed?).to eq false }
    end
  end

  describe "#exchange_required?" do
    context "exchange has been requested and not yet processed" do
      before do
        allow(subject).to receive(:exchange_requested?).and_return(true)
        allow(subject).to receive(:exchange_processed?).and_return(false)
      end

      it { expect(subject.exchange_required?).to be true }
    end

    context "exchange has not been requested" do
      before { allow(subject).to receive(:exchange_requested?).and_return(false) }
      it { expect(subject.exchange_required?).to be false }
    end

    context "exchange has been requested and processed" do
      before do
        allow(subject).to receive(:exchange_requested?).and_return(true)
        allow(subject).to receive(:exchange_processed?).and_return(true)
      end
      it { expect(subject.exchange_required?).to be false }
    end
  end

  describe "#eligible_exchange_variants" do
    it "uses the exchange variant calculator to compute possible variants to exchange for" do
      return_item = build(:return_item)
      expect(Spree::ReturnItem.exchange_variant_engine).to receive(:eligible_variants).with(return_item.variant, stock_locations: nil)
      return_item.eligible_exchange_variants
    end
  end

  describe ".exchange_variant_engine" do
    it "defaults to the same product calculator" do
      expect(Spree::ReturnItem.exchange_variant_engine).to eq Spree::ReturnItem::ExchangeVariantEligibility::SameProduct
    end
  end

  describe "exchange amount" do
    let(:return_item) { build(:return_item) }

    context "the return item is intended to be exchanged" do
      before do
        return_item.inventory_unit.variant.update_column(:track_inventory, false)
        return_item.exchange_variant = return_item.inventory_unit.variant
      end

      it do
        return_item.amount = 5.0
        return_item.save!
        expect(return_item.reload.amount).to eq 0.0
      end
    end

    context "the return item is not intended to be exchanged" do
      it do
        return_item.amount = 5.0
        return_item.save!
        expect(return_item.reload.amount).to eq 5.0
      end
    end
  end

  describe "#build_exchange_inventory_unit" do
    let(:return_item) { build(:return_item) }
    subject { return_item.build_exchange_inventory_unit }

    context "the return item is intended to be exchanged" do
      before { allow(return_item).to receive(:exchange_variant).and_return(mock_model(Spree::Variant)) }

      context "an exchange inventory unit already exists" do
        before { allow(return_item).to receive(:exchange_inventory_unit).and_return(mock_model(Spree::InventoryUnit)) }
        it { expect(subject).to be_nil }
      end

      context "no exchange inventory unit exists" do
        it "builds a pending inventory unit with references to the return item, variant, and previous inventory unit" do
          expect(subject.variant).to eq return_item.exchange_variant
          expect(subject.pending).to eq true
          expect(subject).not_to be_persisted
          expect(subject.original_return_item).to eq return_item
          expect(subject.line_item).to eq return_item.inventory_unit.line_item
        end
      end
    end

    context "the return item is not intended to be exchanged" do
      it { expect(subject).to be_nil }
    end
  end

  describe "#exchange_shipment" do
    it "returns the exchange inventory unit's shipment" do
      inventory_unit = build(:inventory_unit)
      subject.exchange_inventory_unit = inventory_unit
      expect(subject.exchange_shipment).to eq inventory_unit.shipment
    end
  end

  describe "#shipment" do
    it "returns the inventory unit's shipment" do
      inventory_unit = build(:inventory_unit)
      subject.inventory_unit = inventory_unit
      expect(subject.shipment).to eq inventory_unit.shipment
    end
  end

  describe 'inventory_unit uniqueness' do
    let!(:old_return_item) { create(:return_item, reception_status: old_reception_status) }
    let(:old_reception_status) { 'awaiting' }

    subject do
      build(:return_item, {
        return_authorization: old_return_item.return_authorization,
        inventory_unit: old_return_item.inventory_unit
      })
    end

    context 'with other awaiting return items exist for the same inventory unit' do
      let(:old_reception_status) { 'awaiting' }

      it 'cancels the others' do
        expect {
          subject.save!
        }.to change { old_return_item.reload.reception_status }.from('awaiting').to('cancelled')
      end

      it 'does not cancel itself' do
        subject.save!
        expect(subject).to be_awaiting
      end
    end

    context 'with other cancelled return items exist for the same inventory unit' do
      let(:old_reception_status) { 'cancelled' }

      it 'succeeds' do
        subject.save!
      end
    end

    context 'with other received return items exist for the same inventory unit' do
      let(:old_reception_status) { 'received' }

      it 'is invalid' do
        expect(subject).to_not be_valid
        expect(subject.errors.to_a).to eq ["Inventory unit #{subject.inventory_unit_id} has already been taken by return item #{old_return_item.id}"]
      end
    end

    context 'with other given_to_customer return items exist for the same inventory unit' do
      let(:old_reception_status) { 'given_to_customer' }

      it 'is invalid' do
        expect(subject).to_not be_valid
        expect(subject.errors.to_a).to eq ["Inventory unit #{subject.inventory_unit_id} has already been taken by return item #{old_return_item.id}"]
      end
    end
  end

  describe "included tax in total" do
    let(:inventory_unit) { create(:inventory_unit, state: 'shipped') }
    let(:return_item) do
      create(
        :return_item,
        inventory_unit: inventory_unit,
        included_tax_total: 5
      )
    end

    it 'includes included tax total' do
      expect(return_item.amount).to eq 10
      expect(return_item.included_tax_total).to eq 5
      expect(return_item.total).to eq 10
    end
  end

  describe "valid exchange variant" do
    subject { return_item }

    before  { subject.save }

    context "return item doesn't have an exchange variant" do
      let(:return_item) { create(:return_item) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "return item has an exchange variant" do
      let(:return_item)      { create(:exchange_return_item) }
      let(:exchange_variant) { create(:on_demand_variant, product: return_item.inventory_unit.variant.product) }

      context "the exchange variant is eligible" do
        before { return_item.exchange_variant = exchange_variant }

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "the exchange variant is not eligible" do
        context "new return item" do
          let(:return_item)      { build(:return_item) }
          let(:exchange_variant) { create(:variant, product: return_item.inventory_unit.variant.product) }

          before { return_item.exchange_variant = exchange_variant }

          it "is invalid" do
            expect(subject).to_not be_valid
          end

          it "adds an error message about the invalid exchange variant" do
            subject.valid?
            expect(subject.errors.to_a).to eq ["Invalid exchange variant."]
          end
        end

        context "the exchange variant has been updated" do
          before do
            other_variant = create(:variant)
            return_item.exchange_variant_id = other_variant.id
            subject.valid?
          end

          it "is invalid" do
            expect(subject).to_not be_valid
          end

          it "adds an error message about the invalid exchange variant" do
            expect(subject.errors.to_a).to eq ["Invalid exchange variant."]
          end
        end

        context "the exchange variant has not been updated" do
          before do
            other_variant = create(:variant)
            return_item.update_column(:exchange_variant_id, other_variant.id)
            return_item.reload
            subject.valid?
          end

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe '#skip_customer_return_processing=' do
    context 'when it receives a value' do
      let(:return_item) { described_class.new }
      subject { return_item.skip_customer_return_processing = :foo }

      it 'shows a deprecation warning' do
        expect(Spree::Deprecation).to receive(:warn)
        subject
      end
    end
  end
end

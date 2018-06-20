# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement, type: :model do
  describe "display money methods" do
    let(:amount) { 21.22 }
    let(:included_tax_total) { 1.22 }
    let(:additional_tax_total) { 2.55 }
    let(:settlement) {
      build(
        :settlement,
        amount: amount,
        included_tax_total: included_tax_total,
        additional_tax_total: additional_tax_total
      )
    }

    describe "#display_amount" do
      it "returns a Spree::Money" do
        expect(settlement.display_amount).to eq Spree::Money.new(amount)
      end
    end

    describe "#display_total" do
      it "returns a Spree::Money" do
        expect(settlement.display_total).to eq Spree::Money.new(amount + additional_tax_total)
      end
    end

    describe "#display_total_excluding_vat" do
      it "returns a Spree::Money" do
        expect(settlement.display_total_excluding_vat).to eq Spree::Money.new(amount - included_tax_total)
      end
    end
  end

  describe "amount calculations on create" do
    let(:amount) { 21.22 }
    let(:included_tax_total) { 1.22 }

    context "amount is not specified" do
      context "settlement has a shipment" do
        let(:shipment) { create(:shipment) }

        subject { create(:settlement, shipment: shipment) }

        it { expect(subject.amount).to eq subject.shipment.amount }
      end

      context "settlement does not have a shipment" do
        subject { create(:settlement) }

        it { expect(subject.amount).to eq 0 }
      end
    end

    context "amount is specified" do
      subject { create(:settlement, amount: 45) }

      it { expect(subject.amount).to eq 45 }
    end
  end

  describe "acceptance_status state_machine" do
    subject(:settlement) { build(:settlement) }

    it "starts off in the pending state" do
      expect(settlement).to be_pending
    end
  end

  describe "#attempt_accept" do
    let(:settlement) { build(:settlement) }
    let(:validator_errors) { {} }
    let(:validator_double) { double(errors: validator_errors) }

    subject { settlement.attempt_accept! }

    before do
      allow(settlement).to receive(:validator).and_return(validator_double)
    end

    context "pending status" do
      let(:status) { 'pending' }

      before do
        allow(settlement).to receive(:eligible_for_settlement?).and_return(true)
        subject
      end

      it "transitions successfully" do
        expect(settlement).to be_accepted
      end

      it "has no acceptance status errors" do
        expect(settlement.acceptance_status_errors).to be_empty
      end
    end

    context "not eligible for settlement" do
      let(:validator_errors) { { number_of_days: "Settlement is outside the eligible time period" } }

      before do
        settlement.acceptance_status = 'pending'
        allow(settlement).to receive(:eligible_for_settlement?).and_return(false)
      end

      context "manual intervention required" do
        before do
          allow(settlement).to receive(:requires_manual_intervention?).and_return(true)
          subject
        end

        it "transitions to manual intervention required" do
          expect(settlement).to be_manual_intervention_required
        end

        it "sets the acceptance status errors" do
          expect(settlement.acceptance_status_errors).to eq validator_errors
        end
      end

      context "manual intervention not required" do
        before do
          allow(settlement).to receive(:requires_manual_intervention?).and_return(false)
          subject
        end

        it "transitions to rejected" do
          expect(settlement).to be_rejected
        end

        it "sets the acceptance status errors" do
          expect(settlement.acceptance_status_errors).to eq validator_errors
        end
      end
    end
  end

  describe "#reject" do
    let(:settlement) { build(:settlement, acceptance_status: status) }

    subject { settlement.reject! }

    context "manual_intervention_required status" do
      let(:status) { 'manual_intervention_required' }

      before { subject }

      it "transitions successfully" do
        expect(settlement).to be_rejected
      end

      it "has no acceptance status errors" do
        expect(settlement.acceptance_status_errors).to be_empty
      end
    end
  end

  describe "#accept" do
    let(:settlement) { build(:settlement, acceptance_status: status) }

    subject { settlement.accept! }

    context "manual_intervention_required status" do
      let(:status) { 'manual_intervention_required' }

      before { subject }

      it "transitions successfully" do
        expect(settlement).to be_accepted
      end

      it "has no acceptance status errors" do
        expect(settlement.acceptance_status_errors).to be_empty
      end
    end
  end

  describe "validity for shipments" do
    let(:order) { create(:shipped_order) }
    let(:inventory_unit) { order.line_items.first.inventory_units.first }
    let(:return_item) { build_stubbed(:return_item, inventory_unit: inventory_unit, acceptance_status: 'accepted') }
    let(:customer_return) { build(:customer_return, return_items: [return_item], shipped_order: order) }
    let(:reimbursement) { build_stubbed(:reimbursement, customer_return: customer_return, order: order, return_items: [return_item]) }
    let(:settlement) { build(:settlement, reimbursement: reimbursement, shipment: shipment) }

    subject { settlement }

    context "when shipment belongs to same order as reimbursement" do
      let(:shipment) { inventory_unit.shipment }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when shipment does not belong to same order as reimbursement" do
      let(:shipment) { build_stubbed(:shipment) }

      it "is not valid" do
        expect(subject).to_not be_valid
        expect(subject.errors.messages).to eq({ shipment: [I18n.t(:must_belong_to_reimbursement_order, scope: 'activerecord.errors.models.spree/settlement.attributes.shipment')] })
      end
    end
  end

  describe "included tax in total" do
    let(:settlement) { build_stubbed(:settlement, amount: 100, included_tax_total: 10) }

    it "includes included tax total" do
      expect(settlement.amount).to eq 100
      expect(settlement.included_tax_total).to eq 10
      expect(settlement.total).to eq 100
    end
  end

  describe "add tax to total" do
    let(:settlement) { build_stubbed(:settlement, amount: 100, additional_tax_total: 10) }

    it "includes included tax total" do
      expect(settlement.amount).to eq 100
      expect(settlement.additional_tax_total).to eq 10
      expect(settlement.total).to eq 110
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::OrderCompleted do
  let(:shipment)       { create(:shipment, order: order) }
  let(:inventory_unit) { create(:inventory_unit, shipment: shipment) }
  let(:return_item)    { create(:return_item, inventory_unit: inventory_unit, acceptance_status: :accepted) }
  let(:reimbursement)  { create(:reimbursement, order: order, return_items: [return_item]) }
  let(:settlement)     { create(:settlement, shipment: shipment, reimbursement: reimbursement) }
  let(:validator)      { Spree::Settlement::EligibilityValidator::OrderCompleted.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "the order was completed" do
      let(:order) { create(:completed_order_with_totals) }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "the order is not completed" do
      let(:order) { create(:order) }

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:order_not_completed]).to eq I18n.t('spree.settlement_order_not_completed')
      end
    end
  end
end

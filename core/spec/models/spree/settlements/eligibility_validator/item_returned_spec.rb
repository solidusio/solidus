# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::ItemReturned do
  let(:validator) { Spree::Settlement::EligibilityValidator::ItemReturned.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "the shipment shares a return item with the reimbursement" do
      let(:settlement) { create(:settlement) }

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "the shipment does not share a return item with the reimbursement" do
      let(:order) { create(:completed_order_with_totals) }
      let(:shipment) { create(:shipment, order: order) }
      let(:line_item) { order.line_items.first }
      let(:inventory_unit) { line_item.inventory_units.first }
      let(:return_item) { build(:return_item, inventory_unit: inventory_unit, acceptance_status: 'accepted') }
      let(:customer_return) { build(:customer_return, return_items: [return_item]) }
      let(:reimbursement) { create(:reimbursement, customer_return: customer_return, order: order, return_items: [return_item]) }
      let(:settlement) { build(:settlement, shipment: shipment, reimbursement: reimbursement) }

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:item_returned]).to eq I18n.t('spree.settlement_return_items_ineligible')
      end
    end
  end
end

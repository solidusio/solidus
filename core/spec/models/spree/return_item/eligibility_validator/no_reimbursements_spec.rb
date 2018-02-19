# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ReturnItem::EligibilityValidator::NoReimbursements do
  let(:validator) { Spree::ReturnItem::EligibilityValidator::NoReimbursements.new(return_item) }

  describe "#eligible_for_return?" do
    subject { validator.eligible_for_return? }

    context "inventory unit has already been reimbursed" do
      let(:reimbursement) { create(:reimbursement) }
      let(:return_item)   { reimbursement.return_items.last }

      it "returns false" do
        expect(subject).to eq false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:inventory_unit_reimbursed]).to eq I18n.t('spree.return_item_inventory_unit_reimbursed')
      end

      context "but the return item has been expired" do
        before { return_item.expired }

        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "but the return item has been canceled" do
        before { return_item.cancel }

        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "but the return item has been unexchanged" do
        before { return_item.unexchange }

        it "returns true" do
          expect(subject).to eq true
        end
      end
    end

    context "inventory unit has not been reimbursed" do
      let(:return_item) { create(:return_item) }

      it "returns true" do
        expect(subject).to eq true
      end
    end
  end

  describe "#requires_manual_intervention?" do
    subject { validator.requires_manual_intervention? }

    context "not eligible for return" do
      let(:reimbursement) { create(:reimbursement) }
      let(:return_item)   { reimbursement.return_items.last }

      before do
        validator.eligible_for_return?
      end

      it 'returns true if errors were added' do
        expect(subject).to eq true
      end
    end

    context "eligible for return" do
      let(:return_item) { create(:return_item) }

      before do
        validator.eligible_for_return?
      end

      it 'returns false if no errors were added' do
        expect(subject).to eq false
      end
    end
  end
end

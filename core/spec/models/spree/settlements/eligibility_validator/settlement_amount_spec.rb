# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::SettlementAmount do
  let(:settlement) { create(:settlement) }
  let(:validator) { Spree::Settlement::EligibilityValidator::SettlementAmount.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "settlement is associated with a shipment" do
      context "settlement's amount is smaller or equal to shipment's cost" do
        before do
          settlement.shipment.cost = 15
          settlement.amount = 10
        end

        it "returns true" do
          expect(subject).to be true
        end
      end

      context "settlement's amount is greater than shipment's cost" do
        before do
          settlement.shipment.cost = 15
          settlement.amount = 20
        end

        it "returns false" do
          expect(subject).to be false
        end

        it "sets an error" do
          subject
          expect(validator.errors[:settlement_amount]).to eq I18n.t('spree.settlement_amount_greater_than_shipment_cost')
        end
      end
    end

    context "settlement is not associated with a shipment" do
      before do
        settlement.shipment = nil
        settlement.amount = 20
      end

      it "returns true" do
        expect(subject).to be true
      end
    end
  end
end

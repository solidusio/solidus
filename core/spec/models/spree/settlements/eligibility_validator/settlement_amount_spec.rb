# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::SettlementAmount do
  let(:shipment) { create(:shipment) }
  let(:validator) { Spree::Settlement::EligibilityValidator::SettlementAmount.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "settlement is associated with a shipment" do
      let(:settlement) { create(:settlement, shipment: shipment) }

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

      context "settlement's amount is smaller than shipment's cost and shipment has an adjustment" do
        before do
          settlement.shipment.cost = 15
          settlement.amount = 15
          allow(shipment).to receive(:total_before_tax).and_return(10)
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
      let(:settlement) { create(:settlement, shipment: shipment) }

      before do
        settlement.amount = 20
      end

      it "returns true" do
        expect(subject).to be true
      end
    end
  end
end

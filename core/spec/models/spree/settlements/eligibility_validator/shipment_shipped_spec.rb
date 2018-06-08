# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::ShipmentShipped do
  let(:settlement) { create(:settlement) }
  let(:validator) { Spree::Settlement::EligibilityValidator::ShipmentShipped.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "the shipment has been shipped" do
      it "returns true" do
        expect(subject).to be true
      end
    end

    context "the shipment has not been shipped yet" do
      before { allow(settlement.shipment).to receive(:state).and_return(:pending) }

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:shipment_shipped]).to eq I18n.t('spree.settlement_shipment_ineligible')
      end
    end
  end
end

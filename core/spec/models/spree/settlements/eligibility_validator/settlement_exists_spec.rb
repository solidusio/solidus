# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::SettlementExists do
  let(:settlement) { create(:settlement) }
  let(:validator) { Spree::Settlement::EligibilityValidator::SettlementExists.new(settlement) }

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    context "shipment has no existing accepted settlement" do
      it "returns true" do
        expect(subject).to be true
      end
    end

    context "shipment has an existing accepted settlement" do
      let!(:existing_settlement) { settlement.dup }
      before do
        existing_settlement.save!
      end

      it "returns false" do
        expect(subject).to be false
      end

      it "sets an error" do
        subject
        expect(validator.errors[:settlement_already_exists]).to eq I18n.t('spree.settlement_already_exists_for_shipment')
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Settlement::EligibilityValidator::Default, type: :model do
  let(:settlement) { create(:settlement) }
  let(:validator) { Spree::Settlement::EligibilityValidator::Default.new(settlement) }

  let(:item_returned_eligibility_class) { double("ItemReturnedEligibilityValidatorClass") }
  let(:time_eligibility_class) { double("TimeEligibilityValidatorClass") }

  let(:item_returned_eligibility_instance) { double(errors: item_returned_error) }
  let(:time_eligibility_instance) { double(errors: time_error) }

  let(:item_returned_error) { {} }
  let(:time_error) { {} }

  before do
    validator.permitted_eligibility_validators = [item_returned_eligibility_class, time_eligibility_class]

    expect(item_returned_eligibility_class).to receive(:new).and_return(item_returned_eligibility_instance)
    expect(time_eligibility_class).to receive(:new).and_return(time_eligibility_instance)
  end

  describe "#eligible_for_settlement?" do
    subject { validator.eligible_for_settlement? }

    it "checks that all permitted eligibility validators are eligible for settlement" do
      expect(item_returned_eligibility_instance).to receive(:eligible_for_settlement?).and_return(true)
      expect(time_eligibility_instance).to receive(:eligible_for_settlement?).and_return(true)

      expect(subject).to be true
    end
  end

  describe "#requires_manual_intervention?" do
    subject { validator.requires_manual_intervention? }

    context "any of the permitted eligibility validators require manual intervention" do
      it "returns true" do
        expect(item_returned_eligibility_instance).to receive(:requires_manual_intervention?).and_return(false)
        expect(time_eligibility_instance).to receive(:requires_manual_intervention?).and_return(true)

        expect(subject).to be true
      end
    end

    context "no permitted eligibility validators require manual intervention" do
      it "returns false" do
        expect(item_returned_eligibility_instance).to receive(:requires_manual_intervention?).and_return(false)
        expect(time_eligibility_instance).to receive(:requires_manual_intervention?).and_return(false)

        expect(subject).to be false
      end
    end
  end

  describe "#errors" do
    subject { validator.errors }

    context "the validator errors are empty" do
      it "returns an empty hash" do
        expect(subject).to eq({})
      end
    end

    context "the validators have errors" do
      let(:item_returned_error) { { item_returned: item_returned_error_text } }
      let(:time_error) { { time: time_error_text } }

      let(:item_returned_error_text) { "Item returned eligibility error" }
      let(:time_error_text) { "Time eligibility error" }

      it "gathers all errors from permitted eligibility validators into a single errors hash" do
        expect(subject).to eq({ item_returned: item_returned_error_text, time: time_error_text })
      end
    end
  end
end

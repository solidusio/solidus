# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::OptionValue do
  let(:condition) { described_class.new }

  describe "#preferred_eligible_values" do
    subject { condition.preferred_eligible_values }

    it "assigns a nicely formatted hash" do
      condition.preferred_eligible_values = {"5" => "1,2", "6" => "1"}
      expect(subject).to eq({5 => [1, 2], 6 => [1]})
    end
  end

  describe "#eligible?(order)" do
    subject { condition.eligible?(promotable) }

    let(:variant) { create :variant }
    let(:line_item) { create :line_item, variant: variant }
    let(:promotable) { line_item.order }

    context "when there are any applicable line items" do
      before do
        condition.preferred_eligible_values = {line_item.product.id => [
          line_item.variant.option_values.pick(:id)
        ]}
      end

      it { is_expected.to be true }
    end

    context "when there are no applicable line items" do
      before do
        condition.preferred_eligible_values = {99 => [99]}
      end

      it { is_expected.to be false }
    end
  end

  describe "#eligible?(line_item)" do
    subject { condition.eligible?(promotable) }

    let(:variant) { create :variant }
    let(:line_item) { create :line_item, variant: variant }
    let(:promotable) { line_item }

    context "when there are any applicable line items" do
      before do
        condition.preferred_eligible_values = {line_item.product.id => [
          line_item.variant.option_values.pick(:id)
        ]}
      end

      it { is_expected.to be true }
    end

    context "when there are no applicable line items" do
      before do
        condition.preferred_eligible_values = {99 => [99]}
      end

      it { is_expected.to be false }
    end
  end
end

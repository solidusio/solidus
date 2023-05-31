# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::Rules::OptionValue do
  let(:rule) { SolidusFriendlyPromotions::Rules::OptionValue.new }

  describe "#preferred_eligible_values" do
    subject { rule.preferred_eligible_values }
    it "assigns a nicely formatted hash" do
      rule.preferred_eligible_values = Hash["5" => "1,2", "6" => "1"]
      expect(subject).to eq Hash[5 => [1, 2], 6 => [1]]
    end
  end

  describe "#applicable?" do
    subject { rule.applicable?(promotable) }
    context "when promotable is an order" do
      let(:promotable) { Spree::Order.new }
      it { is_expected.to be true }
    end
    context "when promotable is not an order" do
      let(:promotable) { Spree::LineItem.new }
      it { is_expected.to be false }
    end
  end

  describe "#eligible?" do
    let(:variant) { create :variant }
    let(:line_item) { create :line_item, variant: variant }
    let(:promotable) { line_item.order }
    subject { rule.eligible?(promotable) }
    context "when there are any applicable line items" do
      before do
        rule.preferred_eligible_values = Hash[line_item.product.id => [
          line_item.variant.option_values.pluck(:id).first
        ]]
      end
      it { is_expected.to be true }
    end
    context "when there are no applicable line items" do
      before do
        rule.preferred_eligible_values = Hash[99 => [99]]
      end
      it { is_expected.to be false }
    end
  end
end

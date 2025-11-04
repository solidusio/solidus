# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::OrderOptionValue do
  let(:condition) { described_class.new }

  describe "#eligible?(order)" do
    subject { condition.eligible?(promotable) }

    let(:variant) { create :variant }
    let(:line_item) { create :line_item, variant: variant }
    let(:promotable) { line_item.order }

    context "when there are any applicable line items" do
      before do
        condition.preferred_eligible_values = { line_item.product.id => [
          line_item.variant.option_values.pick(:id)
        ] }
      end

      it { is_expected.to be true }
    end

    context "when there are no applicable line items" do
      before do
        condition.preferred_eligible_values = { 99 => [99] }
      end

      it { is_expected.to be false }
    end
  end

  describe "#to_partial_path" do
    subject { condition.to_partial_path }

    it { is_expected.to eq("solidus_promotions/admin/condition_fields/option_value") }
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ItemTotal do
  describe "#recalculate!" do
    subject { described_class.new(item).recalculate! }

    let(:item) { create :line_item, adjustments: }

    let(:tax_rate) { create(:tax_rate) }

    let(:arbitrary_adjustment) { create :adjustment, amount: 1, source: nil }
    let(:included_tax_adjustment) { create :adjustment, amount: 2, source: tax_rate, included: true }
    let(:additional_tax_adjustment) { create :adjustment, amount: 3, source: tax_rate, included: false }

    context "with multiple types of adjustments" do
      let(:adjustments) { [arbitrary_adjustment, included_tax_adjustment, additional_tax_adjustment] }

      it "updates item totals" do
        expect {
          subject
        }.to change(item, :adjustment_total).from(0).to(4).
          and change { item.included_tax_total }.from(0).to(2).
          and change { item.additional_tax_total }.from(0).to(3)
      end
    end

    context "with only an arbitrary adjustment" do
      let(:adjustments) { [arbitrary_adjustment] }

      it "updates the adjustment total" do
        expect {
          subject
        }.to change { item.adjustment_total }.from(0).to(1)
      end
    end

    context "with only tax adjustments" do
      let(:adjustments) { [included_tax_adjustment, additional_tax_adjustment] }

      it "updates the adjustment total" do
        expect {
          subject
        }.to change { item.adjustment_total }.from(0).to(3).
          and change { item.included_tax_total }.from(0).to(2).
          and change { item.additional_tax_total }.from(0).to(3)
      end
    end
  end
end

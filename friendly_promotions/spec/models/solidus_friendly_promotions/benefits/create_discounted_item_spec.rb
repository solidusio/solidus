# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::Benefits::CreateDiscountedItem do
  it { is_expected.to respond_to(:preferred_variant_id) }

  describe "#perform" do
    let(:order) { create(:order_with_line_items) }
    let(:promotion) { create(:friendly_promotion) }
    let(:benefit) { SolidusFriendlyPromotions::Benefits::CreateDiscountedItem.new(preferred_variant_id: goodie.id, calculator: hundred_percent, promotion: promotion) }
    let(:hundred_percent) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 100) }
    let(:goodie) { create(:variant) }
    subject { benefit.perform(order) }

    it "creates a line item with a hundred percent discount" do
      expect { subject }.to change { order.line_items.count }.by(1)
      created_item = order.line_items.detect { |line_item| line_item.managed_by_order_benefit == benefit }
      expect(created_item.discountable_amount).to be_zero
    end

    it "never calls the order recalculator" do
      expect(order).not_to receive(:recalculate)
    end
  end
end

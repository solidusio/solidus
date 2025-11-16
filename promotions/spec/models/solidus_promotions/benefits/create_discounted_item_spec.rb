# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::CreateDiscountedItem do
  it { is_expected.to respond_to(:preferred_variant_id) }

  describe "#can_discount?" do
    let(:benefit) { described_class.new }
    let(:discountable) { Spree::Order.new }

    subject { benefit.can_discount?(discountable) }

    it { is_expected.to be false }

    context "with a line item" do
      let(:discountable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe "#level", :silence_deprecations do
    subject { described_class.new.level }

    it { is_expected.to be :order }
  end

  describe "#perform" do
    let(:order) { create(:order_with_line_items) }
    let(:promotion) { create(:solidus_promotion) }
    let(:benefit) { SolidusPromotions::Benefits::CreateDiscountedItem.new(preferred_variant_id: goodie.id, calculator: hundred_percent, promotion: promotion) }
    let(:hundred_percent) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 100) }
    let(:goodie) { create(:variant) }

    around do |example|
      SolidusPromotions::Promotion.within_lane("default") do
        example.run
      end
    end

    subject { benefit.perform(order) }

    it "creates a line item with a hundred percent discount" do
      expect { subject }.to change { order.line_items.count }.by(1)
      created_item = order.line_items.detect { |line_item| line_item.managed_by_order_benefit == benefit }
      expect(created_item.total_before_tax).to be_zero
    end

    it "never calls the order recalculator" do
      expect(order).not_to receive(:recalculate)
    end
  end
end

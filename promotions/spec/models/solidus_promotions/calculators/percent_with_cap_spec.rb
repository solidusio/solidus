# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Calculators::PercentWithCap, type: :model do
  it_behaves_like "a promotion calculator"

  context "applied to an order" do
    let(:calculator) { described_class.new(preferred_percent: 15, preferred_max_amount: 50) }
    let(:promotion) do
      create(
        :solidus_promotion,
        name: "15% off order. Cap of $30",
        apply_automatically: true
      )
    end

    let(:order) { create(:order) }

    let(:variant_1) { create(:variant, price: 120) }
    let(:variant_2) { create(:variant, price: 230) }
    let(:variant_3) { create(:variant, price: 300) }

    before do
      SolidusPromotions::Benefits::AdjustLineItem.create!(calculator: calculator, promotion: promotion)
      [variant_1, variant_2, variant_3].each do |variant|
        order.contents.add(variant, 1)
      end
    end

    it "correctly distributes the entire discount" do
      expect(order.promo_total).to eq(-50)
      expect(order.line_items.map(&:adjustment_total)).to eq([-9.24, -17.69, -23.07])
    end

    context "with a less expensive order" do
      let(:variant_1) { create(:variant, price: 12) }
      let(:variant_2) { create(:variant, price: 23) }
      let(:variant_3) { create(:variant, price: 10) }

      it "correctly calculates 15%" do
        # 15% of 45 is 6.75, which is less than the max amount of 50
        expect(order.promo_total).to eq(-6.75)
        # 1.8 + 3.45 + 1.5 = 6.75
        expect(order.line_items.map(&:adjustment_total)).to eq([-1.8, -3.45, -1.5])
      end
    end
  end
end

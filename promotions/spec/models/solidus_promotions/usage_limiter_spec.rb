# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::UsageLimiter do
  describe "#limited_records" do
    let(:order) { create(:order_with_line_items) }

    subject { described_class.new(order).send(:limited_records) }

    def connect(promotion)
      order.solidus_order_promotions.create!(promotion:, promotion_code: promotion.codes.first)
    end

    let!(:limited_code) { create(:solidus_promotion, code: "limited", per_code_usage_limit: 1).tap { connect(_1) }.codes.first }
    let!(:limited_coupon_promotion) { create(:solidus_promotion, code: "promo", usage_limit: 1).tap { connect(_1) } }
    let!(:limited_automatic_promotion) do
      create(:solidus_promotion, :with_adjustable_benefit, apply_automatically: true, usage_limit: 1).tap { adjust(_1) }
    end

    def adjust(promotion)
      order.line_items.first.adjustments.create!(order:, source: promotion.benefits.first, amount: -1, label: "Promo")
    end

    before do
      connect(create(:solidus_promotion, code: "unlimited"))
      adjust(create(:solidus_promotion, :with_adjustable_benefit, apply_automatically: true))
      create(:solidus_promotion, code: "other", per_code_usage_limit: 1, usage_limit: 1)
    end

    it "returns the order's usage limited promotions and promotion codes" do
      is_expected.to contain_exactly(limited_code, limited_coupon_promotion, limited_automatic_promotion)
    end
  end
end

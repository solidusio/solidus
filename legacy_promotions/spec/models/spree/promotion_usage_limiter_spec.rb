# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionUsageLimiter do
  describe "#limited_records" do
    let(:order) { create(:order_with_line_items) }

    subject { described_class.new(order).send(:limited_records) }

    def connect(promotion)
      order.order_promotions.create!(promotion:, promotion_code: promotion.codes.first)
    end

    let!(:limited_code) { create(:promotion, code: "limited", per_code_usage_limit: 1).tap { connect(_1) }.codes.first }
    let!(:limited_coupon_promotion) { create(:promotion, code: "promo", usage_limit: 1).tap { connect(_1) } }
    let!(:limited_automatic_promotion) { create(:promotion, apply_automatically: true, usage_limit: 1).tap { connect(_1) } }

    before do
      connect(create(:promotion, code: "unlimited"))
      connect(create(:promotion, apply_automatically: true))
      create(:promotion, code: "other", per_code_usage_limit: 1, usage_limit: 1)
    end

    it "returns the order's usage limited promotions and promotion codes" do
      is_expected.to contain_exactly(limited_code, limited_coupon_promotion, limited_automatic_promotion)
    end
  end
end

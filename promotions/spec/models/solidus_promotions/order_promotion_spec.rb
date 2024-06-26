# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderPromotion do
  subject do
    order_promotion
  end

  let(:promotion) { build(:solidus_promotion) }
  let(:order_promotion) { build(:solidus_order_promotion, promotion: promotion) }

  describe "promotion code presence error" do
    subject do
      order_promotion.valid?
      order_promotion.errors[:promotion_code]
    end

    context "when the promotion does not have a code" do
      it { is_expected.to be_blank }
    end

    context "when the promotion has a code" do
      let!(:promotion_code) do
        promotion.codes << build(:solidus_promotion_code, promotion: promotion)
      end

      it { is_expected.to include("can't be blank") }
    end
  end

  describe "promotion code presence error on promotion that apply automatically" do
    subject do
      order_promotion.promotion.apply_automatically = true
      order_promotion.valid?
      order_promotion.errors[:promotion_code]
    end

    context "when the promotion does not have a code" do
      it { is_expected.to be_blank }
    end

    context "when the promotion has a code" do
      let!(:promotion_code) do
        promotion.codes << build(:solidus_promotion_code, promotion: promotion)
      end

      it { is_expected.to be_blank }
    end
  end
end

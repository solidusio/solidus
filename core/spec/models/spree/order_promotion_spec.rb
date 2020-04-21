# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderPromotion do
  subject do
    order_promotion
  end

  let(:order_promotion) { build(:order_promotion) }

  describe "promotion code presence error" do
    subject do
      order_promotion.valid?
      order_promotion.errors[:promotion_code]
    end

    let(:order_promotion) { build(:order_promotion) }
    let(:promotion) { order_promotion.promotion }

    context "when the promotion does not have a code" do
      it { is_expected.to be_blank }
    end

    context "when the promotion has a code" do
      let!(:promotion_code) do
        promotion.codes << build(:promotion_code, promotion: promotion)
      end

      it { is_expected.to include("can't be blank") }
    end
  end

  describe "promotion code presence error on promotion that apply automatically" do
    subject do
      order_promotion.promotion.apply_automatically = true
      order_promotion.promotion.save!
      order_promotion.valid?
      order_promotion.errors[:promotion_code]
    end

    let(:order_promotion) { build(:order_promotion) }
    let(:promotion) { order_promotion.promotion }

    context "when the promotion does not have a code" do
      it { is_expected.to be_blank }
    end

    context "when the promotion has a code" do
      let!(:promotion_code) do
        promotion.codes << build(:promotion_code, promotion: promotion)
      end

      it { is_expected.to be_blank }
    end
  end
end

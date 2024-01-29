# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::PromotionConfiguration do
  subject(:config) { described_class.new }

  it "uses base searcher class by default" do
    expect(config.promotion_chooser_class).to eq Spree::PromotionChooser
  end

  it "uses order adjustments recalculator class by default" do
    expect(config.promotion_adjuster_class).to eq Spree::Promotion::OrderAdjustmentsRecalculator
  end

  it "uses promotion handler coupon class by default" do
    expect(config.coupon_code_handler_class).to eq Spree::PromotionHandler::Coupon
  end

  it "uses promotion handler shipping class by default" do
    expect(config.shipping_promotion_handler_class).to eq Spree::PromotionHandler::Shipping
  end

  describe "#calculators" do
    subject { config.calculators[promotion_action] }

    context "for Spree::Promotion::Actions::CreateAdjustment" do
      let(:promotion_action) { Spree::Promotion::Actions::CreateAdjustment }

      it {
        is_expected.to contain_exactly(
          Spree::Calculator::FlatPercentItemTotal,
          Spree::Calculator::FlatRate,
          Spree::Calculator::FlexiRate,
          Spree::Calculator::TieredPercent,
          Spree::Calculator::TieredFlatRate
        )
      }
    end

    context "for Spree::Promotion::Actions::CreateItemAdjustments" do
      let(:promotion_action) { Spree::Promotion::Actions::CreateItemAdjustments }

      it {
        is_expected.to contain_exactly(
          Spree::Calculator::DistributedAmount,
          Spree::Calculator::FlatRate,
          Spree::Calculator::FlexiRate,
          Spree::Calculator::PercentOnLineItem,
          Spree::Calculator::TieredPercent
        )
      }
    end

    context "for Spree::Promotion::Actions::CreateQuantityAdjustments" do
      let(:promotion_action) { Spree::Promotion::Actions::CreateQuantityAdjustments }

      it {
        is_expected.to contain_exactly(
          Spree::Calculator::PercentOnLineItem,
          Spree::Calculator::FlatRate
        )
      }
    end
  end
end

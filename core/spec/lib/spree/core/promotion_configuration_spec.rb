# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::PromotionConfiguration do
  describe "#calculators" do
    subject { described_class.new.calculators[promotion_action] }

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

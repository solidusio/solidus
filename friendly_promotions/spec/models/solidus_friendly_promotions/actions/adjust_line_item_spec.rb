# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::Actions::AdjustLineItem do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching line items") }
  end

  describe ".available_calculators" do
    subject { described_class.available_calculators }

    it do
      is_expected.to contain_exactly(
        SolidusFriendlyPromotions::Calculators::DistributedAmount,
        SolidusFriendlyPromotions::Calculators::FlatRate,
        SolidusFriendlyPromotions::Calculators::FlexiRate,
        SolidusFriendlyPromotions::Calculators::Percent,
        SolidusFriendlyPromotions::Calculators::TieredFlatRate,
        SolidusFriendlyPromotions::Calculators::TieredPercent,
      )
    end
  end
end

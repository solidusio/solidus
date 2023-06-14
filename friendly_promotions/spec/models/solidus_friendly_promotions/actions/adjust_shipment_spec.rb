# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::Actions::AdjustShipment do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching shipments") }
  end

  describe ".available_calculators" do
    subject { described_class.available_calculators }

    it do
      is_expected.to contain_exactly(
        SolidusFriendlyPromotions::Calculators::FlatRate,
        SolidusFriendlyPromotions::Calculators::FlexiRate,
        SolidusFriendlyPromotions::Calculators::Percent,
        SolidusFriendlyPromotions::Calculators::TieredFlatRate,
        SolidusFriendlyPromotions::Calculators::TieredPercent,
      )
    end
  end
end

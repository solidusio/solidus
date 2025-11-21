# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::OrderBenefit do
  subject(:benefit_class) do
    Class.new(SolidusPromotions::Benefit) do
      include SolidusPromotions::Benefits::OrderBenefit
    end
  end

  it "warns" do
    expect(Spree.deprecator).to receive(:warn).with(
      "Including SolidusPromotions::Benefits::OrderBenefit is deprecated."
    )
    subject
  end
end

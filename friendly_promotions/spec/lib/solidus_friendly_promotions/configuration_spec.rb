# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Configuration do
  subject { SolidusFriendlyPromotions.config }

  it "has a nice accessor" do
    expect(subject).to be_a(described_class)
  end

  it "is an instance of Spree::Configuration" do
    expect(subject).to be_a(Spree::Preferences::Configuration)
  end

  describe ".promotion_chooser_class" do
    it "is the promotion chooser" do
      expect(subject.promotion_chooser_class).to eq(SolidusFriendlyPromotions::PromotionAdjustmentChooser)
    end
  end
end

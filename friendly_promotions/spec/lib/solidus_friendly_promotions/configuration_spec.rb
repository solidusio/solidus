# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Configuration do
  subject(:config) { SolidusFriendlyPromotions.config }

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

  describe ".shipment_discount_calculators" do
    subject { config.shipment_discount_calculators }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".line_item_discount_calculators" do
    subject { config.line_item_discount_calculators }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".order_rules" do
    subject { config.order_rules }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".line_item_rules" do
    subject { config.line_item_rules }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".shipment_rules" do
    subject { config.line_item_rules }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end
end

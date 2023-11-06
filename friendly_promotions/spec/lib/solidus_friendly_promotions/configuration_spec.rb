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
      expect(subject.discount_chooser_class).to eq(SolidusFriendlyPromotions::DiscountChooser)
    end
  end

  describe ".promotion_calculators" do
    subject { config.promotion_calculators }

    it { is_expected.to be_a(SolidusFriendlyPromotions::NestedClassSet) }
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

  describe ".sync_order_promotions" do
    subject { config.sync_order_promotions }

    it { is_expected.to be true }

    it "can be set to false" do
      config.sync_order_promotions = false
      expect(subject).to be false
      config.sync_order_promotions = true
    end
  end
end

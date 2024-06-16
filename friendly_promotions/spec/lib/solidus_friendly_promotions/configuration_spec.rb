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
      expect(subject.discount_chooser_class).to eq(SolidusFriendlyPromotions::FriendlyPromotionAdjuster::ChooseDiscounts)
    end
  end

  describe ".advertiser_class" do
    it "is the standard advertiser" do
      expect(subject.advertiser_class).to eq(SolidusFriendlyPromotions::PromotionAdvertiser)
    end
  end

  describe ".promotion_calculators" do
    subject { config.promotion_calculators }

    it { is_expected.to be_a(Spree::Core::NestedClassSet) }
  end

  describe ".order_conditions" do
    subject { config.order_conditions }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".line_item_conditions" do
    subject { config.line_item_conditions }

    it { is_expected.to be_a(Spree::Core::ClassConstantizer::Set) }
  end

  describe ".shipment_conditions" do
    subject { config.line_item_conditions }

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

  describe ".recalculate_complete_orders" do
    subject { config.recalculate_complete_orders }

    it { is_expected.to be true }

    it "can be set to false" do
      config.recalculate_complete_orders = false
      expect(subject).to be false
      config.recalculate_complete_orders = true
    end
  end
end

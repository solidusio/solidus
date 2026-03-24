# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::AdvertisePrice do
  subject(:benefit) { described_class.new }

  describe "name" do
    subject(:name) { benefit.model_name.human }

    it { is_expected.to eq("Advertise discounted prices") }
  end

  describe "#can_discount?" do
    subject { benefit.can_discount?(discountable) }

    context "if discountable is a Spree::Price" do
      let(:discountable) { Spree::Price.new }

      it { is_expected.to be true }
    end

    context "if discountable is a Spree::LineItem" do
      let(:discountable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe "#applicable_conditions" do
    subject { described_class.applicable_conditions }

    it { is_expected.to include(SolidusPromotions::Conditions::FirstOrder) }
  end

  describe ".to_partial_path" do
    subject { described_class.new.to_partial_path }

    it { is_expected.to eq("solidus_promotions/admin/benefit_fields/advertise_price") }
  end

  describe "#discount_price" do
    let(:promotion) { build(:solidus_promotion) }
    let(:benefit) { described_class.new(calculator:, promotion:) }
    let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 50) }

    let(:price) { Spree::Price.new(amount: 4, currency: "USD") }

    subject { benefit.discount_price(price) }

    it { is_expected.to be_a(SolidusPromotions::ItemDiscount) }

    it "has a label" do
      expect(subject.label).to eq("Promotion (Because we like you)")
    end

    context "if price already has a discount from the same source" do
      before do
        price.discounts << SolidusPromotions::ItemDiscount.new(amount: -5, source: benefit)
      end

      it "will change the benefit" do
        expect { subject }.to change { price.discounts.first.amount }
      end
    end
  end
end

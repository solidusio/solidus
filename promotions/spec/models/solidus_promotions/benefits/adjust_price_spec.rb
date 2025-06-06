# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::AdjustPrice do
  subject(:benefit) { described_class.new }

  describe "name" do
    subject(:name) { benefit.model_name.human }

    it { is_expected.to eq("Discount prices and matching line items") }
  end

  describe "#can_discount?" do
    subject { benefit.can_discount?(discountable) }

    context "if discountable is a Spree::Price" do
      let(:discountable) { Spree::Price.new }

      it { is_expected.to be true }
    end

    context "if discountable is a Spree::LineItem" do
      let(:discountable) { Spree::LineItem.new }

      it { is_expected.to be true }
    end
  end

  describe "#possible_conditions" do
    subject { benefit.possible_conditions }

    it { pending; is_expected.to include(*SolidusPromotions.config.price_conditions) }
    it { is_expected.to include(*SolidusPromotions.config.order_conditions) }
  end

  describe ".to_partial_path" do
    subject { described_class.new.to_partial_path }

    it { is_expected.to eq("solidus_promotions/admin/benefit_fields/adjust_price") }
  end

  describe "#level" do
    subject { described_class.new.level }

    it { is_expected.to eq(:line_item) }
  end
end

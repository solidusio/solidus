# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Actions::AdjustLineItem do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching line items") }
  end

  describe ".to_partial_path" do
    subject { described_class.new.to_partial_path }

    it { is_expected.to eq("solidus_friendly_promotions/admin/promotion_actions/actions/adjust_line_item") }
  end

  describe "#level" do
    subject { described_class.new.level }

    it { is_expected.to eq(:line_item) }
  end

  describe "#relevant_rules" do
    let!(:promotion) { create(:friendly_promotion, actions: [action], rules: rules) }
    let(:action) { described_class.new(calculator: calculator) }
    let(:calculator) { SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 10) }
    let(:order_rule) { SolidusFriendlyPromotions::Rules::FirstOrder.new }
    let(:line_item_rule) { SolidusFriendlyPromotions::Rules::LineItemProduct.new(products: [product]) }
    let(:product) { create(:product) }
    let(:shipment_rule) { SolidusFriendlyPromotions::Rules::ShippingMethod.new(preferred_shipping_method_ids: [ups.id]) }
    let(:ups) { create(:shipping_method) }
    let(:rules) { [order_rule, line_item_rule, shipment_rule] }

    subject { action.relevant_rules }

    it { is_expected.to contain_exactly(order_rule, line_item_rule) }
  end
end

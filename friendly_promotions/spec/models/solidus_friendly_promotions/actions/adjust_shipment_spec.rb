# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Actions::AdjustShipment do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching shipments") }
  end

  describe "#can_discount?" do
    subject { action.can_discount?(promotable) }

    context "with a line item" do
      let(:promotable) { Spree::Order.new }

      it { is_expected.to be false }
    end

    context "with a shipment" do
      let(:promotable) { Spree::Shipment.new }

      it { is_expected.to be true }
    end

    context "with a shipping rate" do
      let(:promotable) { Spree::ShippingRate.new }

      it { is_expected.to be true }
    end
  end

  describe "#level" do
    subject { described_class.new.level }

    it { is_expected.to eq(:shipment) }
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

    it { is_expected.to contain_exactly(order_rule, shipment_rule) }
  end
end

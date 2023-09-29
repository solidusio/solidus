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
      let(:promotable) { SolidusFriendlyPromotions::Discountable::LineItem.new(Spree::Order.new, order: double) }

      it { is_expected.to be false }
    end

    context "with a shipment" do
      let(:promotable) { SolidusFriendlyPromotions::Discountable::Shipment.new(Spree::Shipment.new, order: double) }

      it { is_expected.to be true }
    end

    context "with a shipping rate" do
      let(:promotable) { SolidusFriendlyPromotions::Discountable::ShippingRate.new(Spree::ShippingRate.new, shipment: double) }

      it { is_expected.to be true }
    end
  end
end

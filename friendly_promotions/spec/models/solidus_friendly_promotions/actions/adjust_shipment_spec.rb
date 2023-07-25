# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::Actions::AdjustShipment do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching shipments") }
  end

  describe "#can_discount?" do
    subject { action.can_discount?(promotable) }

    context "with a line item" do
      let(:promotable) { Spree::LineItem.new }

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
end

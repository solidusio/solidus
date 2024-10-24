# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefits::AdjustShipment do
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
end

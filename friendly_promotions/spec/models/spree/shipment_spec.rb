# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Shipment do
  describe "#discountable_amount" do
    let(:discounts) { [] }
    let(:shipment) { Spree::Shipment.new(amount: 20, current_discounts: discounts) }

    subject(:discountable_amount) { shipment.discountable_amount }

    it { is_expected.to eq(20) }

    context "with a proposed discount" do
      let(:discounts) do
        [
          SolidusFriendlyPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
        ]
      end

      it { is_expected.to eq(18) }
    end

    describe "#reset_current_discounts" do
      let(:shipping_rate) { Spree::ShippingRate.new }
      let(:shipment) { Spree::Shipment.new(shipping_rates: [shipping_rate]) }

      subject { shipment.reset_current_discounts }
      before do
        shipment.current_discounts << SolidusFriendlyPromotions::ItemDiscount.new(item: double, amount: -2, label: "Foo", source: double)
      end

      it "resets the current discounts to an empty array and resets current discounts on all shipping rates" do
        expect(shipping_rate).to receive(:reset_current_discounts)
        expect { subject }.to change { shipment.current_discounts.length }.from(1).to(0)
      end
    end
  end
end

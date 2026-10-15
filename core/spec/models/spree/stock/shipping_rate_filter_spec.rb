# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Stock::ShippingRateFilter do
  describe "#filter" do
    let(:frontend_rate) { Spree::ShippingRate.new(shipping_method: Spree::ShippingMethod.new(available_to_users: true)) }
    let(:backend_rate) { Spree::ShippingRate.new(shipping_method: Spree::ShippingMethod.new(available_to_users: false)) }
    let(:shipping_rates) { [frontend_rate, backend_rate] }

    subject { described_class.new(shipping_rates, frontend_only:).filter }

    context "when frontend_only is true" do
      let(:frontend_only) { true }

      it "removes rates for shipping methods that are not available to users" do
        expect(subject).to eq([frontend_rate])
      end
    end

    context "when frontend_only is false" do
      let(:frontend_only) { false }

      it "keeps every rate" do
        expect(subject).to eq([frontend_rate, backend_rate])
      end
    end
  end
end

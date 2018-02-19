# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ShippingRate, type: :model do
  let(:address) { create(:address) }
  let(:foreign_address) { create :address, country_iso_code: "DE" }
  let(:order) { create :order, ship_address: address }
  let(:shipment) { create(:shipment, order: order) }
  let(:shipping_method) { create(:shipping_method, tax_category: tax_category) }
  let(:tax_category) { create :tax_category }

  subject(:shipping_rate) do
    Spree::ShippingRate.new(
      shipment: shipment,
      shipping_method: shipping_method,
      cost: 10
    )
  end

  context "#display_price" do
    let!(:default_zone) { create :zone, countries: [address.country] }
    let!(:other_zone) { create :zone, countries: [foreign_address.country] }

    before do
      allow(order).to receive(:tax_address).and_return(order_address)
    end

    context 'with one included tax rate' do
      let!(:tax_rate) do
        create :tax_rate,
        included_in_price: true,
        name: "VAT",
        zone: default_zone,
        tax_categories: [tax_category]
      end

      let(:order_address) { address }

      before do
        Spree::Tax::ShippingRateTaxer.new.tax(shipping_rate)
      end

      it "shows correct tax amount" do
        expect(shipping_rate.display_price.to_s).to eq("$10.00 (incl. $0.91 #{tax_rate.name})")
      end

      context "when cost is zero" do
        before do
          shipping_rate.cost = 0
        end

        it "shows no tax amount" do
          expect(shipping_rate.display_price.to_s).to eq("$0.00")
        end
      end
    end

    context 'with one additional tax rate' do
      let!(:tax_rate) do
        create :tax_rate,
        included_in_price: false,
        name: "Sales Tax",
        zone: default_zone,
        tax_categories: [tax_category]
      end

      let(:order_address) { address }

      before do
        Spree::Tax::ShippingRateTaxer.new.tax(shipping_rate)
      end

      it "shows correct tax amount" do
        expect(shipping_rate.display_price.to_s).to eq("$10.00 (+ $1.00 #{tax_rate.name})")
      end

      context "when cost is zero" do
        before do
          shipping_rate.cost = 0
        end

        it "shows no tax amount" do
          expect(shipping_rate.display_price.to_s).to eq("$0.00")
        end
      end
    end

    context 'with two additional tax rates' do
      let!(:tax_rate) do
        create :tax_rate,
        included_in_price: false,
        name: "Sales Tax",
        zone: default_zone,
        tax_categories: [tax_category]
      end

      let!(:other_tax_rate) do
        create :tax_rate,
        included_in_price: false,
        name: "Other Sales Tax",
        zone: default_zone,
        tax_categories: [tax_category],
        amount: 0.05
      end

      let(:order_address) { address }

      before do
        Spree::Tax::ShippingRateTaxer.new.tax(shipping_rate)
      end

      it "shows correct tax amount" do
        expect(shipping_rate.display_price.to_s).to match(/\$10.00 \(.*, .*\)/)
        expect(shipping_rate.display_price.to_s).to include("+ $1.00 Sales Tax")
        expect(shipping_rate.display_price.to_s).to include("+ $0.50 Other Sales Tax")
      end

      context "when cost is zero" do
        before do
          shipping_rate.cost = 0
        end

        it "shows no tax amount" do
          expect(shipping_rate.display_price.to_s).to eq("$0.00")
        end
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3829
  context "#shipping_method" do
    it "can be retrieved" do
      expect(shipping_rate.shipping_method.reload).to eq(shipping_method)
    end

    it "can be retrieved even when deleted" do
      shipping_method.update_column(:deleted_at, Time.current)
      shipping_rate.save
      shipping_rate.reload
      expect(shipping_rate.shipping_method).to eq(shipping_method)
    end
  end

  context "#shipping_method_code" do
    before do
      shipping_method.code = "THE_CODE"
    end

    it 'should be shipping_method.code' do
      expect(shipping_rate.shipping_method_code).to eq("THE_CODE")
    end
  end
end

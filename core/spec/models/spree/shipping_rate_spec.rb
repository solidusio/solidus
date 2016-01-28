# encoding: utf-8

require 'spec_helper'

describe Spree::ShippingRate, type: :model do
  let(:order) { create :order }
  let(:shipment) { create(:shipment, order: order) }
  let(:shipping_method) { create(:shipping_method, tax_category: tax_category) }
  let(:tax_category) { create :tax_category }

  subject(:shipping_rate) { Spree::ShippingRate.new }

  it_behaves_like 'a taxable item'

  context "#display_price" do
    subject(:shipping_rate) do
      create :shipping_rate,
      shipment: shipment,
      shipping_method: shipping_method,
      amount: 10
    end

    let(:default_zone) { create :zone, :with_country, default_tax: true }
    let(:other_zone) { create :zone, :with_country }

    let!(:tax_rate) do
      create :tax_rate,
      included_in_price: included_in_price,
      name: rate_name,
      zone: default_zone,
      tax_category: tax_category
    end

    before do
      allow(order).to receive(:tax_zone).and_return(order_zone)
      Spree::Tax::ItemAdjuster.new(shipping_rate).adjust!
    end

    context 'with one included tax adjustment' do
      let(:included_in_price) { true }
      let(:order_zone) { default_zone }
      let(:rate_name) { "VAT" }

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

    context 'with one tax refund' do
      let(:included_in_price) { true }
      let(:order_zone) { other_zone }
      let(:rate_name) { "VAT" }

      it "shows correct tax amount" do
        expect(shipping_rate.display_price.to_s).to eq("$10.00 (excl. $0.91 #{tax_rate.name})")
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

    context 'with one additional tax adjustment' do
      let(:included_in_price) { false }
      let(:order_zone) { default_zone }
      let(:rate_name) { "Sales tax" }

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
  end

  # Regression test for https://github.com/spree/spree/issues/3829
  context "#shipping_method" do
    subject(:shipping_rate) { create :shipping_rate, shipment: shipment, shipping_method: shipping_method }

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

  context "#tax_rate" do
    let!(:tax_rate) { create(:tax_rate) }

    before do
      shipping_rate.tax_rate = tax_rate
    end

    it "can be retrieved" do
      expect(shipping_rate.tax_rate.reload).to eq(tax_rate)
    end

    it "can be retrieved even when deleted" do
      tax_rate.update_column(:deleted_at, Time.current)
      shipping_rate.save
      shipping_rate.reload
      expect(shipping_rate.tax_rate).to eq(tax_rate)
    end
  end

  context "#shipping_method_code" do
    subject(:shipping_rate) { create :shipping_rate, shipment: shipment, shipping_method: shipping_method }

    before do
      shipping_method.code = "THE_CODE"
    end

    it 'should be shipping_method.code' do
      expect(shipping_rate.shipping_method_code).to eq("THE_CODE")
    end
  end
end

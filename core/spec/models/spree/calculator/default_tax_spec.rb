# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::DefaultTax, type: :model do
  let(:address) { create(:address) }
  let!(:zone) { create(:zone, name: "Country Zone", countries: [tax_rate_country]) }
  let(:tax_rate_country) { address.country }
  let(:tax_category) { create(:tax_category) }
  let(:starts_at) { nil }
  let(:expires_at) { nil }
  let!(:rate) do
    create(:tax_rate, tax_categories: [tax_category], amount: 0.05,
                      included_in_price: included_in_price, zone: zone,
                      starts_at: starts_at, expires_at: expires_at)
  end
  let(:included_in_price) { false }
  subject(:calculator) { Spree::Calculator::DefaultTax.new(calculable: rate ) }

  it_behaves_like 'a calculator with a description'

  context "#compute" do
    context "when given an order" do
      let(:order) do
        create(
          :order_with_line_items,
          line_items_attributes: [
            { price: 10, quantity: 3, tax_category: tax_category }.merge(line_item_one_options),
            { price: 10, quantity: 3, tax_category: tax_category }.merge(line_item_two_options)
          ],
          ship_address: address
        )
      end
      let(:line_item_one_options) { {} }
      let(:line_item_two_options) { {} }

      context "when all items matches the rate's tax category" do
        it "should be equal to the sum of the item totals * rate" do
          expect(calculator.compute(order)).to eq(3)
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(order)).to eq(0)
          end
        end
      end

      context "when no line items match the tax category" do
        let(:other_tax_category) { create(:tax_category) }
        let(:line_item_one_options) { { tax_category: other_tax_category } }
        let(:line_item_two_options) { { tax_category: other_tax_category } }

        it "should be 0" do
          expect(calculator.compute(order)).to eq(0)
        end
      end

      context "when one item matches the tax category" do
        let(:other_tax_category) { create(:tax_category) }
        let(:line_item_two_options) { { tax_category: other_tax_category } }

        it "should be equal to the item total * rate" do
          expect(calculator.compute(order)).to eq(1.5)
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(order)).to eq(0)
          end
        end

        context "correctly rounds to within two decimal places" do
          let(:line_item_one_options) { { price: 10.333, quantity: 1 } }

          specify do
            # Amount is 0.51665, which will be rounded to...
            expect(calculator.compute(order)).to eq(0.52)
          end
        end
      end

      context "when tax is included in price" do
        let(:included_in_price) { true }

        it "will return the deducted amount from the totals" do
          # total price including 5% tax = $60
          # ex pre-tax = $57.14
          # 57.14 + %5 = 59.997 (or "close enough" to $60)
          # 60 - 57.14 = $2.86
          expect(calculator.compute(order).to_f).to eql 2.86
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(order)).to eq(0)
          end
        end
      end
    end
  end

  shared_examples_for 'computing any item' do
    let(:adjustment_total) { 0 }
    let(:adjustments) do
      if adjustment_total.zero?
        []
      else
       [Spree::Adjustment.new(included: false, source: nil, amount: adjustment_total)]
      end
    end
    let(:order) { build_stubbed(:order, ship_address: address) }

    context "when tax is included in price" do
      let(:included_in_price) { true }

      context "when the variant matches the tax category" do
        it "should be equal to the item's full price * rate" do
          expect(calculator.compute(item)).to eql 1.43
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(item)).to eq(0)
          end
        end

        context "when line item is adjusted" do
          let(:adjustment_total) { -1 }

          it "should be equal to the item's adjusted total * rate" do
            expect(calculator.compute(item)).to eql 1.38
          end
        end
      end
    end

    context "when tax is not included in price" do
      context "when the item has an adjustment" do
        let(:adjustment_total) { -1 }

        it "should be equal to the item's pre-tax total * rate" do
          expect(calculator.compute(item)).to eq(1.45)
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(item)).to eq(0)
          end
        end
      end

      context "when the variant matches the tax category" do
        it "should be equal to the item pre-tax total * rate" do
          expect(calculator.compute(item)).to eq(1.50)
        end

        context "when rate is not in its validity period" do
          let(:starts_at) { 1.day.from_now }
          let(:expires_at) { 2.days.from_now }

          it "should be 0" do
            expect(calculator.compute(item)).to eq(0)
          end
        end
      end
    end
  end

  describe 'when given a line item' do
    let(:item) do
      build_stubbed(
        :line_item,
        price: 10,
        quantity: 3,
        adjustments: adjustments,
        order: order,
        tax_category: tax_category
      )
    end

    it_behaves_like 'computing any item'
  end

  describe 'when given a shipment' do
    let(:shipping_method) do
      build_stubbed(
        :shipping_method,
        tax_category: tax_category
      )
    end

    let(:shipping_rate) do
      build_stubbed(
        :shipping_rate,
        selected: true,
        shipping_method: shipping_method
      )
    end

    let(:item) do
      build_stubbed(
        :shipment,
        cost: 30,
        adjustments: adjustments,
        order: order,
        shipping_rates: [shipping_rate]
      )
    end

    it_behaves_like 'computing any item'
  end

  describe 'when given a shipping rate' do
    let(:shipping_method) do
      build_stubbed(
        :shipping_method,
        tax_category: tax_category
      )
    end

    let(:shipment) do
      build_stubbed(
        :shipment,
        order: order
      )
    end

    let(:item) do
      # cost and adjusted amount for shipping rates are the same as they
      # can not be adjusted. for the sake of passing tests, the cost is
      # adjusted here.
      build_stubbed(
        :shipping_rate,
        cost: adjustment_total + 30,
        selected: true,
        shipping_method: shipping_method,
        shipment: shipment
      )
    end

    it_behaves_like 'computing any item'
  end
end

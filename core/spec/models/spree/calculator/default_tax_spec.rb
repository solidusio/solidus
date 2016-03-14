require 'spec_helper'

describe Spree::Calculator::DefaultTax, type: :model do
  let(:address) { create(:address) }
  let!(:zone) { create(:zone, name: "Country Zone", default_tax: true, countries: [tax_rate_country]) }
  let(:tax_rate_country) { address.country }
  let(:tax_category) { create(:tax_category) }
  let!(:rate) { create(:tax_rate, tax_category: tax_category, amount: 0.05, included_in_price: included_in_price, zone: zone) }
  let(:included_in_price) { false }
  subject(:calculator) { Spree::Calculator::DefaultTax.new(calculable: rate ) }

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

        context "when the order's tax address is outside the default VAT zone" do
          let(:order_zone) { create(:zone, countries: [address.country]) }
          let(:default_vat_country) { create(:country, iso: "DE") }

          before do
            rate.zone.update(countries: [default_vat_country])
            # The order has to be reloaded here because of tax zone caching.
            order.reload
          end

          it 'creates a negative amount, indicating a VAT refund' do
            expect(subject.compute(order)).to eq(-2.86)
          end
        end
      end
    end
  end

  shared_examples_for 'computing any item' do
    let(:promo_total) { 0 }
    let(:order) { build_stubbed(:order, ship_address: address) }

    context "when tax is included in price" do
      let(:included_in_price) { true }

      context "when the variant matches the tax category" do
        it "should be equal to the item's full price * rate" do
          expect(calculator.compute(item)).to eql 1.43
        end

        context "when line item is discounted" do
          let(:promo_total) { -1 }

          it "should be equal to the item's discounted total * rate" do
            expect(calculator.compute(item)).to eql 1.38
          end
        end

        context "when the order's tax address is outside the default VAT zone" do
          let!(:order_zone) { create(:zone, countries: [address.country]) }
          let(:default_vat_country) { create(:country, iso: "DE") }

          before do
            rate.zone.update(countries: [default_vat_country])
          end

          it 'creates a negative amount, indicating a VAT refund' do
            expect(subject.compute(item)).to eq(-1.43)
          end
        end
      end
    end

    context "when tax is not included in price" do
      context "when the line item is discounted" do
        let(:promo_total) { -1 }

        it "should be equal to the item's pre-tax total * rate" do
          expect(calculator.compute(item)).to eq(1.45)
        end
      end

      context "when the variant matches the tax category" do
        it "should be equal to the item pre-tax total * rate" do
          expect(calculator.compute(item)).to eq(1.50)
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
        promo_total: promo_total,
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
        promo_total: promo_total,
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
      # cost and discounted_amount for shipping rates are the same as they
      # can not be discounted. for the sake of passing tests, the cost is
      # adjusted here.
      build_stubbed(
        :shipping_rate,
        cost: 30 + promo_total,
        selected: true,
        shipping_method: shipping_method,
        shipment: shipment
      )
    end

    it_behaves_like 'computing any item'
  end
end

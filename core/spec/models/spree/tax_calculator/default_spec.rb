# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::TaxCalculator::Default do
  let(:shipping_address) { FactoryBot.create(:address, state: new_york) }
  let(:order) { FactoryBot.create(:order, ship_address: shipping_address, state: "delivery") }

  let(:new_york) { FactoryBot.create(:state, state_code: "NY") }
  let(:new_york_zone) { FactoryBot.create(:zone, states: [new_york]) }

  let(:books_category) { FactoryBot.create(:tax_category, name: "Books") }
  let!(:book_tax_rate) do
    FactoryBot.create(
      :tax_rate,
      name: "New York Sales Tax",
      tax_categories: [books_category],
      zone: new_york_zone,
      included_in_price: false,
      amount: 0.05
    )
  end

  before do
    book = FactoryBot.create(
      :product,
      price: 20,
      name: "Book",
      tax_category: books_category
    )

    order.contents.add(book.master)
  end

  let(:calculator) { described_class.new(order) }

  describe "#calculate" do
    subject(:calculated_taxes) { calculator.calculate }

    it { is_expected.to be_a Spree::Tax::OrderTax }

    it "has tax information for the line item", aggregate_failures: true do
      expect(calculated_taxes.line_item_taxes.count).to eq 1

      line_item_tax = calculated_taxes.line_item_taxes.first
      expect(line_item_tax.amount).to eq 1
      expect(line_item_tax.included_in_price).to be false
      expect(line_item_tax.tax_rate).to eq book_tax_rate
      expect(line_item_tax.label).to eq "New York Sales Tax 5.0%"
    end

    it "has tax information for the shipments" do
      expect(calculated_taxes.shipment_taxes).to be_empty
    end

    context "with a flat order-level fee" do
      let!(:flat_fee_rate) do
        FactoryBot.create(
          :tax_rate,
          name: "Flat Book Fee",
          tax_categories: [books_category],
          calculator: FactoryBot.build(:flat_fee_calculator),
          zone: new_york_zone,
          amount: 0.27,
          show_rate_in_label: false,
          level: "order"
        )
      end

      it "has tax information for the order", aggregate_failures: true do
        expect(calculated_taxes.order_taxes.count).to eq 1

        order_tax = calculated_taxes.order_taxes.first
        expect(order_tax.amount).to eq 0.27
        expect(order_tax.tax_rate).to eq flat_fee_rate
        expect(order_tax.label).to eq "Flat Book Fee"
      end
    end
  end
end

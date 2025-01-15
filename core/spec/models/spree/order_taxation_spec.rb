# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderTaxation do
  let(:shipping_address) { FactoryBot.create(:address, state: new_york) }
  let(:order) { FactoryBot.create(:order, ship_address: shipping_address, state: "delivery") }

  let(:new_york) { FactoryBot.create(:state, state_code: "NY") }
  let(:new_york_zone) { FactoryBot.create(:zone, states: [new_york]) }

  let(:books_category) { FactoryBot.create(:tax_category, name: "Books") }
  let(:book_tax_rate) do
    FactoryBot.create(
      :tax_rate,
      name: "New York Sales Tax",
      tax_categories: [books_category],
      zone: new_york_zone,
      included_in_price: false,
      amount: 0.05
    )
  end

  let(:book) do
    FactoryBot.create(
      :product,
      price: 20,
      name: "Book",
      tax_category: create(:tax_category),
    )
  end

  let(:taxation) { described_class.new(order) }

  before do
    order.contents.add(book.master)
    book.update(tax_category: books_category)
  end

  describe "#apply" do
    let(:line_item) { order.line_items.first }

    let(:line_item_tax) do
      Spree::Tax::ItemTax.new(
        item_id: line_item.id,
        label: "Tax!",
        tax_rate: book_tax_rate,
        amount: 5,
        included_in_price: false
      )
    end

    let(:taxes) do
      Spree::Tax::OrderTax.new(
        order_id: order.id,
        line_item_taxes: [line_item_tax],
        shipment_taxes: []
      )
    end

    subject(:apply) { taxation.apply(taxes) }

    it "updates the line_item's tax_category_id" do
      expect { apply }.to change {
        line_item[:tax_category_id]
      }.to(books_category.id)
    end

    it "creates a new tax adjustment", aggregate_failures: true do
      apply
      expect(line_item.adjustments.count).to eq 1

      tax_adjustment = line_item.adjustments.first
      expect(tax_adjustment.label).to eq "Tax!"
      expect(tax_adjustment.source).to eq book_tax_rate
      expect(tax_adjustment.amount).to eq 5
      expect(tax_adjustment.included).to be false
    end

    context "when new taxes are applied" do
      before { apply }

      let(:new_line_item_tax) do
        Spree::Tax::ItemTax.new(
          item_id: line_item.id,
          label: "Tax!",
          tax_rate: book_tax_rate,
          amount: 10,
          included_in_price: false
        )
      end

      let(:new_taxes) do
        Spree::Tax::OrderTax.new(
          order_id: order.id,
          line_item_taxes: [new_line_item_tax],
          shipment_taxes: []
        )
      end

      it "updates the existing tax amount", aggregate_failures: true do
        expect {
          taxation.apply(new_taxes)
        }.to change {
          line_item.adjustments.first.amount
        }.from(5).to(10)
      end

      context "and the adjustment is finalized" do
        before do
          line_item.adjustments.first.finalize!
        end

        it "does not update the tax amount", aggregate_failures: true do
          expect {
            taxation.apply(new_taxes)
          }.to change {
            line_item.adjustments.first.amount
          }.from(5).to(10)
        end
      end
    end

    context "when taxes are removed" do
      before { apply }

      let(:new_taxes) do
        Spree::Tax::OrderTax.new(
          order_id: order.id,
          line_item_taxes: [],
          shipment_taxes: []
        )
      end

      it "removes the tax adjustment" do
        expect {
          taxation.apply(new_taxes)
        }.to change {
          line_item.adjustments.count
        }.from(1).to(0)
      end
    end

    context "with order-level taxes" do
      before { apply }

      let(:delivery_fee) do
        FactoryBot.create(
          :tax_rate,
          name: "Delivery Fee",
          tax_categories: [books_category],
          zone: new_york_zone,
          included_in_price: false,
          amount: 0.05
        )
      end

      let(:order_tax) do
        Spree::Tax::ItemTax.new(
          label: "Order Tax!",
          tax_rate: delivery_fee,
          amount: 10,
          included_in_price: false
        )
      end

      let(:taxes) do
        Spree::Tax::OrderTax.new(
          order_id: order.id,
          order_taxes: [order_tax],
          line_item_taxes: [],
          shipment_taxes: []
        )
      end

      it "creates a new tax adjustment", aggregate_failures: true do
        expect(order.adjustments.count).to eq 1

        tax_adjustment = order.adjustments.first
        expect(tax_adjustment.label).to eq "Order Tax!"
        expect(tax_adjustment.source).to eq delivery_fee
        expect(tax_adjustment.order_id).to eq order.id
        expect(tax_adjustment.amount).to eq 10
        expect(tax_adjustment.included).to be false
      end
    end
  end
end

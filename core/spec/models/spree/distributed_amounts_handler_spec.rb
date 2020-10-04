# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::DistributedAmountsHandler, type: :model do
  let(:order) do
    FactoryBot.create(
      :order_with_line_items,
      line_items_attributes: line_items_attributes
    )
  end

  let(:handler) {
    described_class.new(order.line_items, total_amount)
  }

  describe "#amount" do
    let(:total_amount) { 15 }

    context "when there is only one line item" do
      let(:line_items_attributes) { [{ price: 100 }] }
      let(:line_item) { order.line_items.first }

      it "applies the entire amount to the line item" do
        expect(handler.amount(line_item)).to eq(15)
      end
    end

    context "when there are multiple line items" do
      let(:line_items_attributes) do
        [{ price: 50 }, { price: 50 }, { price: 50 }]
      end

      context "and the line items are equally priced" do
        it "evenly distributes the total amount" do
          expect(
            [
              handler.amount(order.line_items[0]),
              handler.amount(order.line_items[1]),
              handler.amount(order.line_items[2])
            ]
          ).to eq(
            [5, 5, 5]
          )
        end

        context "and the total amount cannot be equally distributed" do
          let(:total_amount) { 10 }

          it "applies the remainder of the total amount to the last item" do
            expect(
              [
                handler.amount(order.line_items[0]),
                handler.amount(order.line_items[1]),
                handler.amount(order.line_items[2])
              ]
            ).to match_array(
              [3.33, 3.33, 3.34]
            )
          end
        end
      end

      context "and the line items do not have equal subtotal amounts" do
        let(:line_items_attributes) do
          [{ price: 50, quantity: 3 }, { price: 50, quantity: 1 }, { price: 50, quantity: 2 }]
        end

        it "distributes the total amount relative to the item's price" do
          expect(
            [
              handler.amount(order.line_items[0]),
              handler.amount(order.line_items[1]),
              handler.amount(order.line_items[2])
            ]
          ).to eq(
            [7.5, 2.5, 5]
          )
        end
      end
    end
  end
end

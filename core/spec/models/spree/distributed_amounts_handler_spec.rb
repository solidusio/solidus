require "spec_helper"

RSpec.describe Spree::DistributedAmountsHandler, type: :model do
  let(:order) do
    FactoryGirl.create(
      :order_with_line_items,
      line_items_attributes: line_items_attributes
    )
  end

  describe "#amount" do
    let(:total_amount) { 15 }

    subject { described_class.new(line_item, total_amount).amount }

    context "when there is only one line item" do
      let(:line_items_attributes) { [{ price: 100 }] }
      let(:line_item) { order.line_items.first }

      it "applies the entire amount to the line item" do
        expect(subject).to eq(15)
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
              described_class.new(order.line_items[0], total_amount).amount,
              described_class.new(order.line_items[1], total_amount).amount,
              described_class.new(order.line_items[2], total_amount).amount
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
                described_class.new(order.line_items[0], total_amount).amount,
                described_class.new(order.line_items[1], total_amount).amount,
                described_class.new(order.line_items[2], total_amount).amount
              ]
            ).to eq(
              [3.33, 3.33, 3.34]
            )
          end
        end
      end

      context "and the line items are not equally priced" do
        let(:line_items_attributes) do
          [{ price: 150 }, { price: 50 }, { price: 100 }]
        end

        it "distributes the total amount relative to the item's price" do
          expect(
            [
              described_class.new(order.line_items[0], total_amount).amount,
              described_class.new(order.line_items[1], total_amount).amount,
              described_class.new(order.line_items[2], total_amount).amount
            ]
          ).to eq(
            [7.5, 2.5, 5]
          )
        end
      end
    end
  end
end

require 'spec_helper'
require 'shared_examples/calculator_shared_examples'

describe Spree::Calculator::DistributedAmount, type: :model do
  describe "#compute_line_item" do
    subject { calculator.compute_line_item(order.line_items.first) }

    let(:calculator) { Spree::Calculator::DistributedAmount.new }

    let(:order) do
      FactoryGirl.create(
        :order_with_line_items,
        line_items_attributes: [{ price: 50 }, { price: 50 }, { price: 50 }]
      )
    end

    before do
      calculator.preferred_amount = 15
      calculator.preferred_currency = currency
    end

    context "when the order currency matches the store's currency" do
      let(:currency) { "USD" }
      it { is_expected.to eq 5 }
    end

    context "when the order currency does not match the store's currency" do
      let(:currency) { "CAD" }
      it { is_expected.to eq 0 }
    end
  end
end

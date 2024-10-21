# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/calculator'

RSpec.describe Spree::Calculator::DistributedAmount, type: :model do
  describe "#compute_line_item" do
    subject { calculator.compute_line_item(order.line_items.first) }

    let(:calculator) { Spree::Calculator::DistributedAmount.new }
    let(:promotion) { create(:promotion) }

    let(:order) do
      FactoryBot.create(
        :order_with_line_items,
        line_items_attributes: [{ price: 50 }, { price: 50 }, { price: 50 }]
      )
    end

    before do
      calculator.preferred_amount = 15
      calculator.preferred_currency = currency
      Spree::Promotion::Actions::CreateItemAdjustments.create!(calculator:, promotion:)
    end

    context "when the order currency matches the store's currency" do
      let(:currency) { "USD" }
      it { is_expected.to eq 5 }
      it { is_expected.to be_a BigDecimal }
    end

    context "when the order currency does not match the store's currency" do
      let(:currency) { "CAD" }
      it { is_expected.to eq 0 }
    end
  end
end

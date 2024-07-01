# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::Percent, type: :model do
  context "compute" do
    let(:currency) { "USD" }
    let(:order) { double(currency: currency) }
    let(:line_item) { double("Spree::LineItem", discountable_amount: 100, order: order) }

    before { subject.preferred_percent = 15 }

    it "computes based on item price and quantity" do
      expect(subject.compute(line_item)).to eq 15
    end
  end

  it_behaves_like "a calculator with a description"
end

# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  RSpec.describe Calculator::PercentOnLineItem, type: :model do
    context "compute" do
      let(:line_item) { double("LineItem", amount: 100) }

      before { subject.preferred_percent = 15 }

      it "computes based on item price and quantity" do
        expect(subject.compute(line_item)).to eq 15
      end
    end

    it_behaves_like 'a calculator with a description'
  end
end

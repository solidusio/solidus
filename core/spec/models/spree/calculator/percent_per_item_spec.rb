# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

require_dependency 'spree/calculator'

module Spree
  RSpec.describe Calculator::PercentPerItem, type: :model do
    it_behaves_like 'a calculator with a description'

    describe '#compute' do
      let(:order) { stub_model(Spree::Order) }

      before do
        expect(Spree::Deprecation).to receive(:warn).with(/method is deprecated/)
      end

      it 'warns about deprecation' do
        described_class.new.compute(order)
      end
    end
  end
end

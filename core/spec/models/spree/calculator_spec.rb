# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Calculator, type: :model do
  class SimpleCalculator < Spree::Calculator
    def compute_simple_computable(_line_item)
      'computed'
    end
  end

  class SimpleComputable
  end

  describe "#calculators" do
    subject { Spree::Calculator.calculators }

    it 'returns the (deprecated) calculator step' do
      Spree::Deprecation.silence do
        expect(subject).to be_a Spree::Core::Environment::Calculators
      end
    end
  end

  context "with computable" do
    let(:calculator) { SimpleCalculator.new }
    let(:computable) { SimpleComputable.new }

    subject { SimpleCalculator.new.compute computable }

    it 'calls compute method of class type' do
      expect(subject).to eq  'computed'
    end

    context 'computable does not implement right function name' do
      let(:computable) { Spree::LineItem.new }

      it 'raises an error' do
        expect { subject }.to raise_error NotImplementedError, /Please implement \'compute_line_item\(line_item\)\' in your calculator/
      end
    end
  end
end

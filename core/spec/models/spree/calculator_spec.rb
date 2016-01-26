require 'spec_helper'

describe Spree::Calculator, type: :model do
  class SimpleCalculator < Spree::Calculator
    def compute_simple_computable(_line_item)
      'computed'
    end
  end

  class SimpleComputable
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

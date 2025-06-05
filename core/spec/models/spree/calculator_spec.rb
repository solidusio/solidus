# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Calculator, type: :model do
  let(:simple_calculator_class) do
    Class.new(Spree::Calculator) do
      def self.name
        "SimpleCalculator"
      end

      def compute_simple_computable(_, _options = {})
        "computed"
      end
    end
  end

  let(:simple_computable_class) do
    Class.new do
      def self.name
        "SimpleComputable"
      end
    end
  end

  describe "preferences" do
    subject { simple_calculator_class.new.preferences }

    it { is_expected.to eq({}) }

    context "with preferences stored" do
      let(:calculator) { simple_calculator_class.new(preferences: { a: "1" }) }
      subject { calculator.preferences }

      it { is_expected.to eq({ a: "1" }) }
    end
  end

  context "with computable" do
    let(:calculator) { simple_calculator_class.new }
    let(:computable) { simple_computable_class.new }

    subject { calculator.compute computable }

    it "calls compute method of class type" do
      expect(subject).to eq  "computed"
    end

    context "computable does not implement right function name" do
      let(:computable) { Spree::LineItem.new }

      it "raises an error" do
        expect { subject }.to raise_error NotImplementedError, /Please implement \'compute_line_item\(line_item\)\' in your calculator/
      end
    end

    context "with options" do
      let(:order) { double(Spree::Order) }
      subject { calculator.compute(computable, order: order) }

      it "passes the options to compute_simple_computable" do
        expect(calculator).to receive(:compute_simple_computable).with(computable, order: order)
        subject
      end
    end
  end
end

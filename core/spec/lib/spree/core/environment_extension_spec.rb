# frozen_string_literal: true

require "rails_helper"
require "spree/core/environment_extension"

RSpec.describe Spree::Core::EnvironmentExtension do
  let(:base) {
    Class.new {
      def self.to_s
        "ExampleClass"
      end
    }
  }
  subject! { base.include(described_class).new }

  describe ".add_class_set" do
    let(:class_one) { String }
    let(:class_two) { Array }
    let(:class_three) { Hash }

    context 'with a class set named "foo"' do
      before { base.add_class_set("foo") }

      describe "#foo" do
        it { respond_to?(:foo) }
        it { expect(subject.foo).to be_empty }
        it { expect(subject.foo).to be_kind_of Spree::Core::ClassConstantizer::Set }
      end

      describe "#foo=" do
        it { respond_to?(:foo=) }

        before { subject.foo = [class_one, class_two] }

        it { expect(subject.foo).to include(class_one) }
        it { expect(subject.foo).to include(class_two) }
        it { expect(subject.foo).not_to include(class_three) }
      end
    end

    context "with a default value of [class_one]" do
      before { base.add_class_set("foo", default: [class_one]) }

      describe "#foo" do
        it { respond_to?(:foo) }
        it { expect(subject.foo).to include(class_one) }
        it { expect(subject.foo).to be_kind_of Spree::Core::ClassConstantizer::Set }
      end
    end
  end

  describe ".add_nested_class_set" do
    let(:class_one) { String }
    let(:class_two) { Array }
    let(:class_three) { Hash }

    context 'with a nested class set named "foo"' do
      before { base.add_nested_class_set("foo") }

      describe "#foo" do
        it { respond_to?(:foo) }
        it { expect(subject.foo).to be_kind_of Spree::Core::NestedClassSet }
      end

      describe "#foo=" do
        it { respond_to?(:foo=) }

        before { subject.foo = {"Spree::TaxRate": ["Spree::Calculator::DefaultTax", "Spree::Calculator::FlatFee"]} }

        it { expect(subject.foo[Spree::TaxRate]).to include(Spree::Calculator::DefaultTax) }
        it { expect(subject.foo[Spree::TaxRate]).to include(Spree::Calculator::FlatFee) }
        it { expect(subject.foo[Spree::TaxRate]).not_to include(Spree::Calculator::Shipping::FlexiRate) }
      end
    end

    context "setting defaults" do
      before { base.add_nested_class_set("foo", default: {"Spree::TaxRate": ["Spree::Calculator::DefaultTax", "Spree::Calculator::FlatFee"]}) }

      describe "#foo" do
        it { respond_to?(:foo) }
        it { expect(subject.foo[Spree::TaxRate]).to include(Spree::Calculator::DefaultTax) }
        it { expect(subject.foo[Spree::TaxRate]).to include(Spree::Calculator::FlatFee) }
        it { expect(subject.foo[Spree::TaxRate]).not_to include(Spree::Calculator::Shipping::FlexiRate) }
      end
    end
  end
end

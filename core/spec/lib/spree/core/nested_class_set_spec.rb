# frozen_string_literal: true

require "rails_helper"
require "spree/core/nested_class_set"

RSpec.describe Spree::Core::NestedClassSet do
  subject { described_class.new(hash) }

  let(:hash) do
    {
      "Spree::TaxRate" => ["Spree::Calculator::DefaultTax"],
      "Spree::ShippingMethod" => ["Spree::Calculator::Shipping::FlatRate"]
    }
  end

  describe "#[]" do
    it "returns the set of classes for the given class" do
      expect(subject[Spree::TaxRate].to_a).to eq [Spree::Calculator::DefaultTax]
    end

    it "works if just given a string" do
      expect(subject["Spree::TaxRate"].to_a).to eq [Spree::Calculator::DefaultTax]
    end

    it "returns nil if the class is not found" do
      expect(subject[String]).to eq([])
    end
  end

  describe "#[]=" do
    it "returns the set of classes for the given class" do
      subject[Spree::TaxRate] = [Spree::Calculator::FlatFee]
      expect(subject[Spree::TaxRate].to_a).to eq [Spree::Calculator::FlatFee]
    end

    it "works if just given a string" do
      subject["Spree::TaxRate"] = ["Spree::Calculator::FlatFee"]
      expect(subject["Spree::TaxRate"].to_a).to eq [Spree::Calculator::FlatFee]
    end
  end

  context "run time changes" do
    describe "adding an key class" do
      let(:klass) { Spree::TaxRate }
      let(:value) { Spree::Calculator::FlatFee }

      it "adds the class to the set" do
        subject.klass_sets[klass.name] << value
        expect(subject[Spree::TaxRate].to_a).to eq [Spree::Calculator::DefaultTax, Spree::Calculator::FlatFee]
      end
    end

    describe "adding a calculator class to an existing value" do
      let(:klass) { Spree::ShippingMethod }
      let(:value) { Spree::Calculator::Shipping::FlatRate }

      it "adds the class to the set" do
        subject.klass_sets[klass.name] << value
        expect(subject[klass].to_a).to eq([Spree::Calculator::Shipping::FlatRate])
      end
    end
  end
end

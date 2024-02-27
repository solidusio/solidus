# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::Environment::Calculators do
  subject { described_class.new }

  describe "#shipping_methods" do
    it "is empty by default" do
      expect(subject.shipping_methods).to be_empty
    end

    it "can be set to a new value" do
      subject.shipping_methods = ["Spree::Calculator::Shipping::FlatRate"]
      expect(subject.shipping_methods).to include(Spree::Calculator::Shipping::FlatRate)
    end
  end

  describe "#tax_rates" do
    it "is empty by default" do
      expect(subject.tax_rates).to be_empty
    end

    it "can be set to a new value" do
      subject.tax_rates = ["Spree::Calculator::Shipping::FlatRate"]
      expect(subject.tax_rates).to include(Spree::Calculator::Shipping::FlatRate)
    end
  end
end

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

  describe "deprecated methods" do
    around do |example|
      Spree.deprecator.silence do
        example.run
      end
    end

    describe "#promotion_actions_create_adjustments" do
      it "contains the default calculators" do
        expect(subject.promotion_actions_create_adjustments).to eq(Spree::Config.promotions.calculators["Spree::Promotion::Actions::CreateAdjustment"])
      end

      it "can be set to a new value" do
        previous_value = subject.promotion_actions_create_adjustments
        subject.promotion_actions_create_adjustments = ["Spree::Calculator::FlatRate"]
        expect(subject.promotion_actions_create_adjustments).to include(Spree::Calculator::FlatRate)
        subject.promotion_actions_create_adjustments = previous_value
      end
    end

    describe "#promotion_actions_create_item_adjustments" do
      it "contains the default calculators" do
        expect(subject.promotion_actions_create_item_adjustments).to eq(Spree::Config.promotions.calculators["Spree::Promotion::Actions::CreateItemAdjustments"])
      end

      it "can be set to a new value" do
        previous_value = subject.promotion_actions_create_item_adjustments
        subject.promotion_actions_create_item_adjustments = ["Spree::Calculator::FlatRate"]
        expect(subject.promotion_actions_create_item_adjustments).to include(Spree::Calculator::FlatRate)
        subject.promotion_actions_create_item_adjustments = previous_value
      end
    end
    describe "#promotion_actions_create_quantity_adjustments" do
      it "contains the default calculators" do
        expect(subject.promotion_actions_create_quantity_adjustments).to eq(Spree::Config.promotions.calculators["Spree::Promotion::Actions::CreateQuantityAdjustments"])
      end

      it "can be set to a new value" do
        previous_value = subject.promotion_actions_create_quantity_adjustments
        subject.promotion_actions_create_quantity_adjustments = ["Spree::Calculator::FlatRate"]
        expect(subject.promotion_actions_create_quantity_adjustments).to include(Spree::Calculator::FlatRate)
        subject.promotion_actions_create_quantity_adjustments = previous_value
      end
    end
  end
end

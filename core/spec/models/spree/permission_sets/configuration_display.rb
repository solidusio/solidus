# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/dummy_ability"

RSpec.describe Spree::PermissionSets::ConfigurationDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:read, Spree::TaxCategory) }
    it { is_expected.to be_able_to(:read, Spree::TaxRate) }
    it { is_expected.to be_able_to(:read, Spree::Zone) }
    it { is_expected.to be_able_to(:read, Spree::Country) }
    it { is_expected.to be_able_to(:read, Spree::State) }
    it { is_expected.to be_able_to(:read, Spree::PaymentMethod) }
    it { is_expected.to be_able_to(:read, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:read, Spree::ShippingMethod) }
    it { is_expected.to be_able_to(:read, Spree::ShippingCategory) }
    it { is_expected.to be_able_to(:read, Spree::StockLocation) }
    it { is_expected.to be_able_to(:read, Spree::StockMovement) }
    it { is_expected.to be_able_to(:read, Spree::RefundReason) }
    it { is_expected.to be_able_to(:read, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:read, Spree::ReturnReason) }
    it { is_expected.to be_able_to(:admin, Spree::TaxCategory) }
    it { is_expected.to be_able_to(:admin, Spree::TaxRate) }
    it { is_expected.to be_able_to(:admin, Spree::Zone) }
    it { is_expected.to be_able_to(:admin, Spree::Country) }
    it { is_expected.to be_able_to(:admin, Spree::State) }
    it { is_expected.to be_able_to(:admin, Spree::PaymentMethod) }
    it { is_expected.to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.to be_able_to(:admin, Spree::ShippingMethod) }
    it { is_expected.to be_able_to(:admin, Spree::ShippingCategory) }
    it { is_expected.to be_able_to(:admin, Spree::StockLocation) }
    it { is_expected.to be_able_to(:admin, Spree::StockMovement) }
    it { is_expected.to be_able_to(:admin, Spree::RefundReason) }
    it { is_expected.to be_able_to(:admin, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:admin, Spree::ReturnReason) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:read, Spree::TaxCategory) }
    it { is_expected.not_to be_able_to(:read, Spree::TaxRate) }
    it { is_expected.not_to be_able_to(:read, Spree::Zone) }
    it { is_expected.not_to be_able_to(:read, Spree::Country) }
    it { is_expected.not_to be_able_to(:read, Spree::State) }
    it { is_expected.not_to be_able_to(:read, Spree::PaymentMethod) }
    it { is_expected.not_to be_able_to(:read, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:read, Spree::ShippingMethod) }
    it { is_expected.not_to be_able_to(:read, Spree::ShippingCategory) }
    it { is_expected.not_to be_able_to(:read, Spree::StockLocation) }
    it { is_expected.not_to be_able_to(:read, Spree::StockMovement) }
    it { is_expected.not_to be_able_to(:read, Spree::RefundReason) }
    it { is_expected.not_to be_able_to(:read, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:read, Spree::ReturnReason) }
    it { is_expected.not_to be_able_to(:admin, Spree::TaxCategory) }
    it { is_expected.not_to be_able_to(:admin, Spree::TaxRate) }
    it { is_expected.not_to be_able_to(:admin, Spree::Zone) }
    it { is_expected.not_to be_able_to(:admin, Spree::Country) }
    it { is_expected.not_to be_able_to(:admin, Spree::State) }
    it { is_expected.not_to be_able_to(:admin, Spree::PaymentMethod) }
    it { is_expected.not_to be_able_to(:admin, Spree::Taxonomy) }
    it { is_expected.not_to be_able_to(:admin, Spree::ShippingMethod) }
    it { is_expected.not_to be_able_to(:admin, Spree::ShippingCategory) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockLocation) }
    it { is_expected.not_to be_able_to(:admin, Spree::StockMovement) }
    it { is_expected.not_to be_able_to(:admin, Spree::RefundReason) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReturnReason) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:display)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:configuration)
    end
  end
end

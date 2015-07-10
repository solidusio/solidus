require 'spec_helper'

describe Spree::PermissionSets::ConfigurationDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:edit, :general_settings) }
    it { should be_able_to(:display, Spree::TaxCategory) }
    it { should be_able_to(:display, Spree::TaxRate) }
    it { should be_able_to(:display, Spree::Zone) }
    it { should be_able_to(:display, Spree::Country) }
    it { should be_able_to(:display, Spree::State) }
    it { should be_able_to(:display, Spree::PaymentMethod) }
    it { should be_able_to(:display, Spree::Taxonomy) }
    it { should be_able_to(:display, Spree::ShippingMethod) }
    it { should be_able_to(:display, Spree::ShippingCategory) }
    it { should be_able_to(:display, Spree::StockLocation) }
    it { should be_able_to(:display, Spree::StockMovement) }
    it { should be_able_to(:display, Spree::Tracker) }
    it { should be_able_to(:display, Spree::RefundReason) }
    it { should be_able_to(:display, Spree::ReimbursementType) }
    it { should be_able_to(:display, Spree::ReturnReason) }
    it { should be_able_to(:admin, :general_settings) }
    it { should be_able_to(:admin, Spree::TaxCategory) }
    it { should be_able_to(:admin, Spree::TaxRate) }
    it { should be_able_to(:admin, Spree::Zone) }
    it { should be_able_to(:admin, Spree::Country) }
    it { should be_able_to(:admin, Spree::State) }
    it { should be_able_to(:admin, Spree::PaymentMethod) }
    it { should be_able_to(:admin, Spree::Taxonomy) }
    it { should be_able_to(:admin, Spree::ShippingMethod) }
    it { should be_able_to(:admin, Spree::ShippingCategory) }
    it { should be_able_to(:admin, Spree::StockLocation) }
    it { should be_able_to(:admin, Spree::StockMovement) }
    it { should be_able_to(:admin, Spree::Tracker) }
    it { should be_able_to(:admin, Spree::RefundReason) }
    it { should be_able_to(:admin, Spree::ReimbursementType) }
    it { should be_able_to(:admin, Spree::ReturnReason) }
  end

  context "when not activated" do
    it { should_not be_able_to(:edit, :general_settings) }
    it { should_not be_able_to(:display, Spree::TaxCategory) }
    it { should_not be_able_to(:display, Spree::TaxRate) }
    it { should_not be_able_to(:display, Spree::Zone) }
    it { should_not be_able_to(:display, Spree::Country) }
    it { should_not be_able_to(:display, Spree::State) }
    it { should_not be_able_to(:display, Spree::PaymentMethod) }
    it { should_not be_able_to(:display, Spree::Taxonomy) }
    it { should_not be_able_to(:display, Spree::ShippingMethod) }
    it { should_not be_able_to(:display, Spree::ShippingCategory) }
    it { should_not be_able_to(:display, Spree::StockLocation) }
    it { should_not be_able_to(:display, Spree::StockMovement) }
    it { should_not be_able_to(:display, Spree::Tracker) }
    it { should_not be_able_to(:display, Spree::RefundReason) }
    it { should_not be_able_to(:display, Spree::ReimbursementType) }
    it { should_not be_able_to(:display, Spree::ReturnReason) }
    it { should_not be_able_to(:admin, :general_settings) }
    it { should_not be_able_to(:admin, Spree::TaxCategory) }
    it { should_not be_able_to(:admin, Spree::TaxRate) }
    it { should_not be_able_to(:admin, Spree::Zone) }
    it { should_not be_able_to(:admin, Spree::Country) }
    it { should_not be_able_to(:admin, Spree::State) }
    it { should_not be_able_to(:admin, Spree::PaymentMethod) }
    it { should_not be_able_to(:admin, Spree::Taxonomy) }
    it { should_not be_able_to(:admin, Spree::ShippingMethod) }
    it { should_not be_able_to(:admin, Spree::ShippingCategory) }
    it { should_not be_able_to(:admin, Spree::StockLocation) }
    it { should_not be_able_to(:admin, Spree::StockMovement) }
    it { should_not be_able_to(:admin, Spree::Tracker) }
    it { should_not be_able_to(:admin, Spree::RefundReason) }
    it { should_not be_able_to(:admin, Spree::ReimbursementType) }
    it { should_not be_able_to(:admin, Spree::ReturnReason) }
  end
end


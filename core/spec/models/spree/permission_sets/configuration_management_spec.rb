require 'spec_helper'

describe Spree::PermissionSets::ConfigurationManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, :general_settings) }
    it { should be_able_to(:manage, Spree::TaxCategory) }
    it { should be_able_to(:manage, Spree::TaxRate) }
    it { should be_able_to(:manage, Spree::Zone) }
    it { should be_able_to(:manage, Spree::Country) }
    it { should be_able_to(:manage, Spree::State) }
    it { should be_able_to(:manage, Spree::PaymentMethod) }
    it { should be_able_to(:manage, Spree::Taxonomy) }
    it { should be_able_to(:manage, Spree::ShippingMethod) }
    it { should be_able_to(:manage, Spree::ShippingCategory) }
    it { should be_able_to(:manage, Spree::StockLocation) }
    it { should be_able_to(:manage, Spree::StockMovement) }
    it { should be_able_to(:manage, Spree::Tracker) }
    it { should be_able_to(:manage, Spree::RefundReason) }
    it { should be_able_to(:manage, Spree::ReimbursementType) }
    it { should be_able_to(:manage, Spree::ReturnReason) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, :general_settings) }
    it { should_not be_able_to(:manage, Spree::TaxCategory) }
    it { should_not be_able_to(:manage, Spree::TaxRate) }
    it { should_not be_able_to(:manage, Spree::Zone) }
    it { should_not be_able_to(:manage, Spree::Country) }
    it { should_not be_able_to(:manage, Spree::State) }
    it { should_not be_able_to(:manage, Spree::PaymentMethod) }
    it { should_not be_able_to(:manage, Spree::Taxonomy) }
    it { should_not be_able_to(:manage, Spree::ShippingMethod) }
    it { should_not be_able_to(:manage, Spree::ShippingCategory) }
    it { should_not be_able_to(:manage, Spree::StockLocation) }
    it { should_not be_able_to(:manage, Spree::StockMovement) }
    it { should_not be_able_to(:manage, Spree::Tracker) }
    it { should_not be_able_to(:manage, Spree::RefundReason) }
    it { should_not be_able_to(:manage, Spree::ReimbursementType) }
    it { should_not be_able_to(:manage, Spree::ReturnReason) }
  end
end


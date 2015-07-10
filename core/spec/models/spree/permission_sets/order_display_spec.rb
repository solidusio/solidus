require 'spec_helper'

describe Spree::PermissionSets::OrderDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:display, Spree::Order) }
    it { should be_able_to(:display, Spree::Payment) }
    it { should be_able_to(:display, Spree::Shipment) }
    it { should be_able_to(:display, Spree::Adjustment) }
    it { should be_able_to(:display, Spree::LineItem) }
    it { should be_able_to(:display, Spree::ReturnAuthorization) }
    it { should be_able_to(:display, Spree::CustomerReturn) }
    it { should be_able_to(:admin, Spree::Order) }
    it { should be_able_to(:admin, Spree::Payment) }
    it { should be_able_to(:admin, Spree::Shipment) }
    it { should be_able_to(:admin, Spree::Adjustment) }
    it { should be_able_to(:admin, Spree::LineItem) }
    it { should be_able_to(:admin, Spree::ReturnAuthorization) }
    it { should be_able_to(:admin, Spree::CustomerReturn) }
    it { should be_able_to(:edit, Spree::Order) }
    it { should be_able_to(:cart, Spree::Order) }
  end

  context "when not activated" do
    it { should_not be_able_to(:display, Spree::Order) }
    it { should_not be_able_to(:display, Spree::Payment) }
    it { should_not be_able_to(:display, Spree::Shipment) }
    it { should_not be_able_to(:display, Spree::Adjustment) }
    it { should_not be_able_to(:display, Spree::LineItem) }
    it { should_not be_able_to(:display, Spree::ReturnAuthorization) }
    it { should_not be_able_to(:display, Spree::CustomerReturn) }
    it { should_not be_able_to(:admin, Spree::Order) }
    it { should_not be_able_to(:admin, Spree::Payment) }
    it { should_not be_able_to(:admin, Spree::Shipment) }
    it { should_not be_able_to(:admin, Spree::Adjustment) }
    it { should_not be_able_to(:admin, Spree::LineItem) }
    it { should_not be_able_to(:admin, Spree::ReturnAuthorization) }
    it { should_not be_able_to(:admin, Spree::CustomerReturn) }
    it { should_not be_able_to(:cart, Spree::Order) }
  end
end


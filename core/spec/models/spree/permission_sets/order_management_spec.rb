require 'spec_helper'

describe Spree::PermissionSets::OrderManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, Spree::Order) }
    it { should be_able_to(:manage, Spree::Payment) }
    it { should be_able_to(:manage, Spree::Shipment) }
    it { should be_able_to(:manage, Spree::Adjustment) }
    it { should be_able_to(:manage, Spree::LineItem) }
    it { should be_able_to(:manage, Spree::ReturnAuthorization) }
    it { should be_able_to(:manage, Spree::CustomerReturn) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, Spree::Order) }
    it { should_not be_able_to(:manage, Spree::Payment) }
    it { should_not be_able_to(:manage, Spree::Shipment) }
    it { should_not be_able_to(:manage, Spree::Adjustment) }
    it { should_not be_able_to(:manage, Spree::LineItem) }
    it { should_not be_able_to(:manage, Spree::ReturnAuthorization) }
    it { should_not be_able_to(:manage, Spree::CustomerReturn) }
  end
end


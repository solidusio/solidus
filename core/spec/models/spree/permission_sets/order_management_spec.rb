require 'spec_helper'

describe Spree::PermissionSets::OrderManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Spree::Order) }
    it { is_expected.to be_able_to(:manage, Spree::Payment) }
    it { is_expected.to be_able_to(:manage, Spree::Shipment) }
    it { is_expected.to be_able_to(:manage, Spree::Adjustment) }
    it { is_expected.to be_able_to(:manage, Spree::LineItem) }
    it { is_expected.to be_able_to(:manage, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:manage, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:display, Spree::ReimbursementType) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree::Order) }
    it { is_expected.not_to be_able_to(:manage, Spree::Payment) }
    it { is_expected.not_to be_able_to(:manage, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:manage, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:manage, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:manage, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:manage, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:display, Spree::ReimbursementType) }
  end
end


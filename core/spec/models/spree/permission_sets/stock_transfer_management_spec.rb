require 'spec_helper'

describe Spree::PermissionSets::StockTransferManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Spree::StockTransfer) }
    it { is_expected.to be_able_to(:manage, Spree::TransferItem) }
    it { is_expected.to be_able_to(:display, Spree::StockLocation) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:manage, Spree::StockTransfer) }
    it { is_expected.to_not be_able_to(:manage, Spree::TransferItem) }
    it { is_expected.not_to be_able_to(:display, Spree::StockLocation) }
  end
end

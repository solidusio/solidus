require 'spec_helper'

describe Solidus::PermissionSets::StockTransferManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Solidus::StockTransfer) }
    it { is_expected.to be_able_to(:manage, Solidus::TransferItem) }
    it { is_expected.to be_able_to(:display, Solidus::StockLocation) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:manage, Solidus::StockTransfer) }
    it { is_expected.to_not be_able_to(:manage, Solidus::TransferItem) }
    it { is_expected.not_to be_able_to(:display, Solidus::StockLocation) }
  end
end



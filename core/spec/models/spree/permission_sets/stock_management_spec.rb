require 'spec_helper'

describe Spree::PermissionSets::StockManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, Spree::StockItem) }
    it { should be_able_to(:manage, Spree::StockTransfer) }
    it { should be_able_to(:manage, Spree::TransferItem) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, Spree::StockItem) }
    it { should_not be_able_to(:manage, Spree::StockTransfer) }
    it { should_not be_able_to(:manage, Spree::TransferItem) }
  end
end


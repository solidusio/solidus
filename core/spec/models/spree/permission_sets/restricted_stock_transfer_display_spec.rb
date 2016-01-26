require 'spec_helper'

describe Spree::PermissionSets::RestrictedStockTransferDisplay do
  let(:ability) { Spree::Ability.new(user) }
  let(:user) { create :user }

  subject { ability }

  let!(:sl1) { create :stock_location, active: false }
  let!(:sl2) { create :stock_location, active: false }

  let!(:source_transfer) { create :stock_transfer, source_location: sl1 }
  let!(:other_source_transfer) { create :stock_transfer, source_location: sl2 }
  let!(:dest_transfer) { create :stock_transfer, source_location: sl2, destination_location: sl1 }

  before do
    user.stock_locations << sl1
  end

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, sl1) }
    it { is_expected.to_not be_able_to(:display, sl2) }

    it { is_expected.to be_able_to(:display, source_transfer) }
    it { is_expected.to_not be_able_to(:display, other_source_transfer) }
    it { is_expected.to be_able_to(:display, dest_transfer) }

    it { is_expected.to be_able_to(:admin, source_transfer) }
    it { is_expected.to_not be_able_to(:admin, other_source_transfer) }
    it { is_expected.to be_able_to(:admin, dest_transfer) }
  end

  context "when not activated" do
    it { is_expected.to_not be_able_to(:display, sl1) }
    it { is_expected.to_not be_able_to(:display, sl2) }

    it { is_expected.to_not be_able_to(:display, source_transfer) }
    it { is_expected.to_not be_able_to(:display, other_source_transfer) }
    it { is_expected.to_not be_able_to(:display, dest_transfer) }

    it { is_expected.to_not be_able_to(:admin, source_transfer) }
    it { is_expected.to_not be_able_to(:admin, other_source_transfer) }
    it { is_expected.to_not be_able_to(:admin, dest_transfer) }
  end
end

require 'spec_helper'

describe Solidus::PermissionSets::UserDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Spree.user_class) }
    it { is_expected.to be_able_to(:admin, Spree.user_class) }
    it { is_expected.to be_able_to(:edit, Spree.user_class) }
    it { is_expected.to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.to be_able_to(:orders, Spree.user_class) }
    it { is_expected.to be_able_to(:items, Spree.user_class) }
    it { is_expected.to be_able_to(:display, Solidus::StoreCredit) }
    it { is_expected.to be_able_to(:admin, Solidus::StoreCredit) }
    it { is_expected.to be_able_to(:display, Solidus::Role) }
    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Spree.user_class) }
    it { is_expected.not_to be_able_to(:admin, Spree.user_class) }
    it { is_expected.not_to be_able_to(:edit, Spree.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.not_to be_able_to(:orders, Spree.user_class) }
    it { is_expected.not_to be_able_to(:items, Spree.user_class) }
    it { is_expected.not_to be_able_to(:display, Solidus::StoreCredit) }
    it { is_expected.not_to be_able_to(:admin, Solidus::StoreCredit) }
    it { is_expected.not_to be_able_to(:display, Solidus::Role) }
  end
end


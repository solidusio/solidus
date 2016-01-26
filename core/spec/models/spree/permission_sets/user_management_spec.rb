require 'spec_helper'

describe Spree::PermissionSets::UserManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:admin, Spree.user_class) }
    it { is_expected.to be_able_to(:display, Spree.user_class) }
    it { is_expected.to be_able_to(:create, Spree.user_class) }
    it { is_expected.to be_able_to(:update, Spree.user_class) }
    it { is_expected.to be_able_to(:save_in_address_book, Spree.user_class) }
    it { is_expected.to be_able_to(:remove_from_address_book, Spree.user_class) }
    it { is_expected.to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.to be_able_to(:orders, Spree.user_class) }
    it { is_expected.to be_able_to(:items, Spree.user_class) }

    it { is_expected.to be_able_to(:update_email, Spree.user_class.new(spree_roles: [])) }
    it { is_expected.not_to be_able_to(:update_email, Spree.user_class.new(spree_roles: [create(:role)])) }

    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }

    it { is_expected.to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.to be_able_to(:display, Spree::Role) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree.user_class) }
    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.not_to be_able_to(:update, Spree.user_class) }
    it { is_expected.not_to be_able_to(:save_in_address_book, Spree.user_class) }
    it { is_expected.not_to be_able_to(:remove_from_address_book, Spree.user_class) }
    it { is_expected.not_to be_able_to(:addresses, Spree.user_class) }
    it { is_expected.not_to be_able_to(:orders, Spree.user_class) }
    it { is_expected.not_to be_able_to(:items, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.not_to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.not_to be_able_to(:display, Spree::Role) }
  end
end

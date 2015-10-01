require 'spec_helper'

describe Spree::PermissionSets::UserManagement do
  let(:user) { create(:user) }
  let(:ability) { DummyAbility.new(user) }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it "can manage users with no roles" do
      expect(ability).to be_able_to :manage, create(:user)
    end

    it "cannot manage users with roles" do
      # to protect against a privelege-escalation vulnerability whereby
      # the lower-level admin changes a higher-level admin's email
      # address to an email address the lower-level admin has access to,
      # thus taking over a higher-level admin account

      expect(ability).not_to be_able_to :manage, create(:admin_user)
    end

    it "can manage itself even with roles" do
      expect(ability).to be_able_to :manage, user
    end

    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.to be_able_to(:display, Spree::Role) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree.user_class) }
    it { is_expected.not_to be_able_to(:delete, Spree.user_class) }
    it { is_expected.not_to be_able_to(:destroy, Spree.user_class) }
    it { is_expected.not_to be_able_to(:manage, Spree::StoreCredit) }
    it { is_expected.not_to be_able_to(:display, Spree::Role) }
  end
end


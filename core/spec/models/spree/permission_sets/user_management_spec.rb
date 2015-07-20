require 'spec_helper'

describe Spree::PermissionSets::UserManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, Spree.user_class) }
    it { should_not be_able_to(:delete, Spree.user_class) }
    it { should_not be_able_to(:destroy, Spree.user_class) }
    it { should be_able_to(:manage, Spree::StoreCredit) }
    it { should be_able_to(:display, Spree::Role) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, Spree.user_class) }
    it { should_not be_able_to(:delete, Spree.user_class) }
    it { should_not be_able_to(:destroy, Spree.user_class) }
    it { should_not be_able_to(:manage, Spree::StoreCredit) }
    it { should_not be_able_to(:display, Spree::Role) }
  end
end


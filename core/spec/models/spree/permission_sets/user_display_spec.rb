require 'spec_helper'

describe Spree::PermissionSets::UserDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:display, Spree.user_class) }
    it { should be_able_to(:admin, Spree.user_class) }
    it { should be_able_to(:edit, Spree.user_class) }
    it { should be_able_to(:addresses, Spree.user_class) }
    it { should be_able_to(:orders, Spree.user_class) }
    it { should be_able_to(:items, Spree.user_class) }
    it { should be_able_to(:display, Spree::StoreCredit) }
    it { should be_able_to(:admin, Spree::StoreCredit) }
    it { should be_able_to(:display, Spree::Role) }
  end

  context "when not activated" do
    it { should_not be_able_to(:display, Spree.user_class) }
    it { should_not be_able_to(:admin, Spree.user_class) }
    it { should_not be_able_to(:edit, Spree.user_class) }
    it { should_not be_able_to(:addresses, Spree.user_class) }
    it { should_not be_able_to(:orders, Spree.user_class) }
    it { should_not be_able_to(:items, Spree.user_class) }
    it { should_not be_able_to(:display, Spree::StoreCredit) }
    it { should_not be_able_to(:admin, Spree::StoreCredit) }
    it { should_not be_able_to(:display, Spree::Role) }
  end
end


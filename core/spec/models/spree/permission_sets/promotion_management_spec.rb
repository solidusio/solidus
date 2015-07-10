require 'spec_helper'

describe Spree::PermissionSets::PromotionManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:manage, Spree::Promotion) }
    it { should be_able_to(:manage, Spree::PromotionRule) }
    it { should be_able_to(:manage, Spree::PromotionAction) }
    it { should be_able_to(:manage, Spree::PromotionCategory) }
  end

  context "when not activated" do
    it { should_not be_able_to(:manage, Spree::Promotion) }
    it { should_not be_able_to(:manage, Spree::PromotionRule) }
    it { should_not be_able_to(:manage, Spree::PromotionAction) }
    it { should_not be_able_to(:manage, Spree::PromotionCategory) }
  end
end


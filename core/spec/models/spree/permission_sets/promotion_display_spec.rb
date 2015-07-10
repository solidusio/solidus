require 'spec_helper'

describe Spree::PermissionSets::PromotionDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { should be_able_to(:display, Spree::Promotion) }
    it { should be_able_to(:display, Spree::PromotionRule) }
    it { should be_able_to(:display, Spree::PromotionAction) }
    it { should be_able_to(:display, Spree::PromotionCategory) }
    it { should be_able_to(:admin, Spree::Promotion) }
    it { should be_able_to(:admin, Spree::PromotionRule) }
    it { should be_able_to(:admin, Spree::PromotionAction) }
    it { should be_able_to(:admin, Spree::PromotionCategory) }
  end

  context "when not activated" do
    it { should_not be_able_to(:display, Spree::Promotion) }
    it { should_not be_able_to(:display, Spree::PromotionRule) }
    it { should_not be_able_to(:display, Spree::PromotionAction) }
    it { should_not be_able_to(:display, Spree::PromotionCategory) }
    it { should_not be_able_to(:admin, Spree::Promotion) }
    it { should_not be_able_to(:admin, Spree::PromotionRule) }
    it { should_not be_able_to(:admin, Spree::PromotionAction) }
    it { should_not be_able_to(:admin, Spree::PromotionCategory) }
  end
end


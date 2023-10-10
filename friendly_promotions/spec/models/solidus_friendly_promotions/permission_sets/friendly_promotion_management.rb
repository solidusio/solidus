# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

RSpec.describe SolidusFriendlyPromotions::PermissionSets::FriendlyPromotionManagement do
  let(:ability_klass) do
    Class.new do
      include CanCan::Ability
    end
  end
  let(:ability) { ability_klass.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, SolidusFriendlyPromotions::Promotion) }
    it { is_expected.to be_able_to(:manage, SolidusFriendlyPromotions::PromotionRule) }
    it { is_expected.to be_able_to(:manage, SolidusFriendlyPromotions::PromotionAction) }
    it { is_expected.to be_able_to(:manage, SolidusFriendlyPromotions::PromotionCategory) }
    it { is_expected.to be_able_to(:manage, SolidusFriendlyPromotions::PromotionCode) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, SolidusFriendlyPromotions::Promotion) }
    it { is_expected.not_to be_able_to(:manage, SolidusFriendlyPromotions::PromotionRule) }
    it { is_expected.not_to be_able_to(:manage, SolidusFriendlyPromotions::PromotionAction) }
    it { is_expected.not_to be_able_to(:manage, SolidusFriendlyPromotions::PromotionCategory) }
    it { is_expected.not_to be_able_to(:manage, SolidusFriendlyPromotions::PromotionCode) }
  end
end

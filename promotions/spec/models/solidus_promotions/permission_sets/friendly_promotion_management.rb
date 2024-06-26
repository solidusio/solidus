# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe SolidusPromotions::PermissionSets::FriendlyPromotionManagement do
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

    it { is_expected.to be_able_to(:manage, SolidusPromotions::Promotion) }
    it { is_expected.to be_able_to(:manage, SolidusPromotions::Condition) }
    it { is_expected.to be_able_to(:manage, SolidusPromotions::Benefit) }
    it { is_expected.to be_able_to(:manage, SolidusPromotions::PromotionCategory) }
    it { is_expected.to be_able_to(:manage, SolidusPromotions::PromotionCode) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, SolidusPromotions::Promotion) }
    it { is_expected.not_to be_able_to(:manage, SolidusPromotions::Condition) }
    it { is_expected.not_to be_able_to(:manage, SolidusPromotions::Benefit) }
    it { is_expected.not_to be_able_to(:manage, SolidusPromotions::PromotionCategory) }
    it { is_expected.not_to be_able_to(:manage, SolidusPromotions::PromotionCode) }
  end
end

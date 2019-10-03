# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::PromotionDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Solidus::Promotion) }
    it { is_expected.to be_able_to(:display, Solidus::PromotionRule) }
    it { is_expected.to be_able_to(:display, Solidus::PromotionAction) }
    it { is_expected.to be_able_to(:display, Solidus::PromotionCategory) }
    it { is_expected.to be_able_to(:display, Solidus::PromotionCode) }
    it { is_expected.to be_able_to(:admin, Solidus::Promotion) }
    it { is_expected.to be_able_to(:admin, Solidus::PromotionRule) }
    it { is_expected.to be_able_to(:admin, Solidus::PromotionAction) }
    it { is_expected.to be_able_to(:admin, Solidus::PromotionCategory) }
    it { is_expected.to be_able_to(:admin, Solidus::PromotionCode) }
    it { is_expected.to be_able_to(:edit, Solidus::Promotion) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Solidus::Promotion) }
    it { is_expected.not_to be_able_to(:display, Solidus::PromotionRule) }
    it { is_expected.not_to be_able_to(:display, Solidus::PromotionAction) }
    it { is_expected.not_to be_able_to(:display, Solidus::PromotionCategory) }
    it { is_expected.not_to be_able_to(:display, Solidus::PromotionCode) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Promotion) }
    it { is_expected.not_to be_able_to(:admin, Solidus::PromotionRule) }
    it { is_expected.not_to be_able_to(:admin, Solidus::PromotionAction) }
    it { is_expected.not_to be_able_to(:admin, Solidus::PromotionCategory) }
    it { is_expected.not_to be_able_to(:admin, Solidus::PromotionCode) }
    it { is_expected.not_to be_able_to(:edit, Solidus::Promotion) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::PromotionManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Solidus::Promotion) }
    it { is_expected.to be_able_to(:manage, Solidus::PromotionRule) }
    it { is_expected.to be_able_to(:manage, Solidus::PromotionAction) }
    it { is_expected.to be_able_to(:manage, Solidus::PromotionCategory) }
    it { is_expected.to be_able_to(:manage, Solidus::PromotionCode) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Solidus::Promotion) }
    it { is_expected.not_to be_able_to(:manage, Solidus::PromotionRule) }
    it { is_expected.not_to be_able_to(:manage, Solidus::PromotionAction) }
    it { is_expected.not_to be_able_to(:manage, Solidus::PromotionCategory) }
    it { is_expected.not_to be_able_to(:manage, Solidus::PromotionCode) }
  end
end

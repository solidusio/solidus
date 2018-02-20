# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::PromotionDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Spree::Promotion) }
    it { is_expected.to be_able_to(:display, Spree::PromotionRule) }
    it { is_expected.to be_able_to(:display, Spree::PromotionAction) }
    it { is_expected.to be_able_to(:display, Spree::PromotionCategory) }
    it { is_expected.to be_able_to(:display, Spree::PromotionCode) }
    it { is_expected.to be_able_to(:admin, Spree::Promotion) }
    it { is_expected.to be_able_to(:admin, Spree::PromotionRule) }
    it { is_expected.to be_able_to(:admin, Spree::PromotionAction) }
    it { is_expected.to be_able_to(:admin, Spree::PromotionCategory) }
    it { is_expected.to be_able_to(:admin, Spree::PromotionCode) }
    it { is_expected.to be_able_to(:edit, Spree::Promotion) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Spree::Promotion) }
    it { is_expected.not_to be_able_to(:display, Spree::PromotionRule) }
    it { is_expected.not_to be_able_to(:display, Spree::PromotionAction) }
    it { is_expected.not_to be_able_to(:display, Spree::PromotionCategory) }
    it { is_expected.not_to be_able_to(:display, Spree::PromotionCode) }
    it { is_expected.not_to be_able_to(:admin, Spree::Promotion) }
    it { is_expected.not_to be_able_to(:admin, Spree::PromotionRule) }
    it { is_expected.not_to be_able_to(:admin, Spree::PromotionAction) }
    it { is_expected.not_to be_able_to(:admin, Spree::PromotionCategory) }
    it { is_expected.not_to be_able_to(:admin, Spree::PromotionCode) }
    it { is_expected.not_to be_able_to(:edit, Spree::Promotion) }
  end
end

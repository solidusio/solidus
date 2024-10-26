# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Adjustment do
  describe ".promotion" do
    let(:spree_promotion_action) { create(:promotion, :with_action).actions.first }
    let!(:spree_promotion_action_adjustment) { create(:adjustment, source: spree_promotion_action) }
    let(:solidus_promotion_benefit) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }
    let!(:solidus_promotion_benefit_adjustment) { create(:adjustment, source: solidus_promotion_benefit) }
    let(:tax_rate) { create(:tax_rate) }
    let!(:tax_adjustment) { create(:adjustment, source: tax_rate) }

    subject { described_class.promotion }

    it { is_expected.to contain_exactly(solidus_promotion_benefit_adjustment, spree_promotion_action_adjustment) }
  end

  describe ".solidus_promotion" do
    let(:spree_promotion_action) { create(:promotion, :with_action).actions.first }
    let!(:spree_promotion_action_adjustment) { create(:adjustment, source: spree_promotion_action) }
    let(:solidus_promotion_benefit) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }
    let!(:solidus_promotion_benefit_adjustment) { create(:adjustment, source: solidus_promotion_benefit) }
    let(:tax_rate) { create(:tax_rate) }
    let!(:tax_adjustment) { create(:adjustment, source: tax_rate) }

    subject { described_class.solidus_promotion }

    it { is_expected.to contain_exactly(solidus_promotion_benefit_adjustment) }
  end

  describe "#promotion?" do
    let(:source) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }
    let!(:adjustment) { build(:adjustment, source: source) }

    subject { adjustment.promotion? }

    it { is_expected.to be true }

    context "with a Spree Promotion Action source" do
      let(:source) { create(:promotion, :with_action).actions.first }

      it { is_expected.to be true }
    end

    context "with a Tax Rate source" do
      let(:source) { create(:tax_rate) }

      it { is_expected.to be false }
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "solidus_friendly_promotions/promotion_migrator"
require "solidus_friendly_promotions/promotion_map"
require "solidus_friendly_promotions/migrate_adjustments"

RSpec.describe SolidusFriendlyPromotions::MigrateAdjustments do
  let(:promotion) { create(:promotion, :with_adjustable_action) }
  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:tax_rate) { create(:tax_rate) }

  before do
    line_item.adjustments.create!(
      source: tax_rate,
      amount: -3,
      label: "Business tax",
      eligible: true,
      included: true,
      order: order
    )
    line_item.adjustments.create!(
      source: promotion.actions.first,
      amount: -2,
      label: "Promotion (Because we like you)",
      eligible: true,
      order: order
    )
    SolidusFriendlyPromotions::PromotionMigrator.new(
      SolidusFriendlyPromotions::PROMOTION_MAP
    ).call
  end

  describe ".up" do
    subject { described_class.up }

    it "migrates our adjustment" do
      spree_promotion_action = Spree::PromotionAction.first
      friendly_promotion_action = SolidusFriendlyPromotions::PromotionAction.first
      expect { subject }.to change {
        Spree::Adjustment.promotion.first.source
      }.from(spree_promotion_action).to(friendly_promotion_action)
    end

    it "will not touch tax adjustments" do
      expect { subject }.not_to change {
        Spree::Adjustment.tax.first.attributes
      }
    end
  end

  describe ".down" do
    subject { described_class.down }

    before do
      described_class.up
    end

    it "migrates our adjustment" do
      spree_promotion_action = Spree::PromotionAction.first
      friendly_promotion_action = SolidusFriendlyPromotions::PromotionAction.first
      expect { subject }.to change {
        Spree::Adjustment.promotion.first.source
      }.from(friendly_promotion_action).to(spree_promotion_action)
    end

    it "will not touch tax adjustments" do
      expect { subject }.not_to change {
        Spree::Adjustment.tax.first.attributes
      }
    end
  end
end

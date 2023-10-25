# frozen_string_literal: true

namespace :solidus_friendly_promotions do
  namespace :migrate_adjustments do
    desc "Migrate adjustments with Spree::PromotionAction sources to SolidusFriendlyPromotions::PromotionAction sources"
    task up: :environment do
      require "solidus_friendly_promotions/migrate_adjustments"
      SolidusFriendlyPromotions::MigrateAdjustments.up
    end

    desc "Migrate adjustments with SolidusFriendlyPromotions::PromotionAction sources to Spree::PromotionAction sources"
    task down: :environment do
      require "solidus_friendly_promotions/migrate_adjustments"
      SolidusFriendlyPromotions::MigrateAdjustments.down
    end
  end
end

# frozen_string_literal: true

namespace :solidus_friendly_promotions do
  namespace :migrate_adjustments do
    desc "Migrate adjustments with Spree::Benefit sources to SolidusFriendlyPromotions::Benefit sources"
    task up: :environment do
      require "solidus_friendly_promotions/migrate_adjustments"
      SolidusFriendlyPromotions::MigrateAdjustments.up
    end

    desc "Migrate adjustments with SolidusFriendlyPromotions::Benefit sources to Spree::Benefit sources"
    task down: :environment do
      require "solidus_friendly_promotions/migrate_adjustments"
      SolidusFriendlyPromotions::MigrateAdjustments.down
    end
  end
end

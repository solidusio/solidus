# frozen_string_literal: true

namespace :solidus_promotions do
  namespace :migrate_adjustments do
    desc "Migrate adjustments with Spree::Benefit sources to SolidusPromotions::Benefit sources"
    task up: :environment do
      require "solidus_promotions/migrate_adjustments"
      SolidusPromotions::MigrateAdjustments.up
    end

    desc "Migrate adjustments with SolidusPromotions::Benefit sources to Spree::Benefit sources"
    task down: :environment do
      require "solidus_promotions/migrate_adjustments"
      SolidusPromotions::MigrateAdjustments.down
    end
  end
end

# frozen_string_literal: true

require "solidus_friendly_promotions/promotion_migrator"

namespace :solidus_friendly_promotions do
  desc "Migrate Spree Promotions to Friendly Promotions using a map"
  task migrate_existing_promotions: :environment do
    require "solidus_friendly_promotions/promotion_map"

    SolidusFriendlyPromotions::PromotionMigrator.new(SolidusFriendlyPromotions::PROMOTION_MAP).call
  end
end

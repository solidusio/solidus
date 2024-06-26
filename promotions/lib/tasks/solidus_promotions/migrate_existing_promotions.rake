# frozen_string_literal: true

require "solidus_promotions/promotion_migrator"

namespace :solidus_promotions do
  desc "Migrate Spree Promotions to Friendly Promotions using a map"
  task migrate_existing_promotions: :environment do
    require "solidus_promotions/promotion_map"

    SolidusPromotions::PromotionMigrator.new(SolidusPromotions::PROMOTION_MAP).call
  end
end

# frozen_string_literal: true

namespace :solidus_friendly_promotions do
  namespace :migrate_order_promotions do
    desc "Migrate order promotions from Spree::OrderPromotion sources to SolidusFriendlyPromotions::FriendlyOrderPromotion sources"
    task up: :environment do
      require "solidus_friendly_promotions/migrate_order_promotions"
      SolidusFriendlyPromotions::MigrateOrderPromotions.up
    end

    desc "Migrate order promotions from SolidusFriendlyPromotions::FriendlyOrderPromotion sources to Spree::OrderPromotion sources"
    task down: :environment do
      require "solidus_friendly_promotions/migrate_order_promotions"
      SolidusFriendlyPromotions::MigrateOrderPromotions.down
    end
  end
end

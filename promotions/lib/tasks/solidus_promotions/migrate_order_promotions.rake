# frozen_string_literal: true

namespace :solidus_promotions do
  namespace :migrate_order_promotions do
    desc "Migrate order promotions from Spree::OrderPromotion sources to SolidusPromotions::FriendlyOrderPromotion sources"
    task up: :environment do
      require "solidus_promotions/migrate_order_promotions"
      SolidusPromotions::MigrateOrderPromotions.up
    end

    desc "Migrate order promotions from SolidusPromotions::FriendlyOrderPromotion sources to Spree::OrderPromotion sources"
    task down: :environment do
      require "solidus_promotions/migrate_order_promotions"
      SolidusPromotions::MigrateOrderPromotions.down
    end
  end
end

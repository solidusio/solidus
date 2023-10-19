# frozen_string_literal: true

module SolidusFriendlyPromotions
  module OrderRecalculatorDecorator
    def recalculate
      if SolidusFriendlyPromotions.config.sync_order_promotions
        MigrationSupport::OrderPromotionSyncer.new(order: order).call
      end
      super
    end
    Spree::Config.order_recalculator_class.prepend self
  end
end

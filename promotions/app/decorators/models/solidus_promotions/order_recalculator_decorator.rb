# frozen_string_literal: true

module SolidusPromotions
  module OrderRecalculatorDecorator
    def recalculate
      if SolidusPromotions.config.sync_order_promotions
        MigrationSupport::OrderPromotionSyncer.new(order: order).call
      end
      super
    end
    Spree::Config.order_recalculator_class.prepend self
  end
end

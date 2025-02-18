# frozen_string_literal: true

module SolidusPromotions
  module OrderRecalculatorPatch
    # This is only needed for stores upgrading from the legacy promotion system.
    # Once we've removed support for the legacy promotion system, we can remove this.
    def recalculate
      if SolidusPromotions.config.sync_order_promotions
        MigrationSupport::OrderPromotionSyncer.new(order: order).call
      end
      super
    end
    Spree::Config.order_recalculator_class.prepend self
  end
end
